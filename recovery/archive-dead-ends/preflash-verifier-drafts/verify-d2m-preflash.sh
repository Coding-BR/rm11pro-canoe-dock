#!/usr/bin/env bash
set -euo pipefail

# Read-only D2M preflash gate for RM11 Pro / NX809J.
# D2M bakes in the live-proven decrypt stack:
# qsee full D2K compat, gatekeeper/boot/keystore2 libc++ only, and TWRP keystore2.

FOX_DIR="${FOX_DIR:-<orangefox-tree>}"
ARTIFACT_DIR="${ARTIFACT_DIR:-<local-build-root>/recovery-forensics/d2m-auto-decrypt-libcxx-keystore}"
IMAGE="${IMAGE:-${ARTIFACT_DIR}/OrangeFox-R12.0-Unofficial-NX809J-d2m-auto-decrypt-libcxx-keystore.img}"
EXPECTED_BYTES="${EXPECTED_BYTES:-104857600}"
EXPECTED_SHA256="${EXPECTED_SHA256:-7a08ab7aaa14d839b5642507a4608710900d054a7af9724b35a385e2d13dac3a}"
EXPECTED_FINGERPRINT_PART="${EXPECTED_FINGERPRINT_PART:-orangefox_NX809J_codingbr_d2m}"
EXPECTED_MARKER="${EXPECTED_MARKER:-ro.rm11.decrypt_candidate_d2m=d2m-auto-decrypt-libcxx-keystore}"
EXPECTED_TOUCH_MARKER="${EXPECTED_TOUCH_MARKER:-ro.rm11.touch_candidate_d1t3=d1t3-minuitwrp-touch-normalization}"
EXPECTED_KEYSTORE2_SHA256="${EXPECTED_KEYSTORE2_SHA256:-0637318bd2540f40b132ac72dd63fbd017d35d0b393ced7bbf997d3a16d04ca9}"
EXPECTED_LIBCXX_SHA256="${EXPECTED_LIBCXX_SHA256:-2267f93b8b3c9d1967f1833d5f71c7312213c43bb291250cf772800763037fb9}"

PRODUCT="orangefox_NX809J_codingbr_d2m"
DEVICE_DIR="${FOX_DIR}/device/zte/sm88XX"
AVBTOOL="${FOX_DIR}/external/avb/avbtool.py"
TWRP_CPP="${FOX_DIR}/bootable/recovery/twrp.cpp"
UNPACK_SCRIPT="${UNPACK_SCRIPT:-<repo-root>/scripts/recovery/unpack-android-boot-lz4.sh}"
UNPACK_DIR="${UNPACK_DIR:-${ARTIFACT_DIR}/verify-unpack-$(date +%Y%m%d-%H%M%S)}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$*"
}

need_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

need_dir() {
  [ -d "$1" ] || fail "missing directory: $1"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing command: $1"
}

contains_literal() {
  local file="$1"
  local text="$2"
  local label="$3"
  grep -Fq "$text" "$file" || fail "$label not found in $file"
  pass "$label"
}

reject_literal() {
  local root="$1"
  local text="$2"
  local label="$3"
  if grep -R -Fq "$text" "$root" 2>/dev/null; then
    fail "$label found under $root"
  fi
  pass "$label absent"
}

check_sha() {
  local file="$1"
  local expected="$2"
  local label="$3"
  local actual
  actual="$(sha256sum "$file" | awk '{print $1}')"
  [ "$actual" = "$expected" ] || fail "$label sha256 mismatch: got ${actual}, expected ${expected}"
  pass "$label sha256 matches"
}

assert_rc_has() {
  local file="$1"
  local text="$2"
  local label="$3"
  need_file "$file"
  contains_literal "$file" "$text" "$label"
}

assert_rc_lacks() {
  local file="$1"
  local text="$2"
  local label="$3"
  need_file "$file"
  if grep -Fq "$text" "$file"; then
    fail "$label unexpectedly present in $file"
  fi
  pass "$label absent"
}

check_strongbox_side_lane() {
  local rc="$1"
  local label="$2"
  need_file "$rc"
  contains_literal "$rc" 'disabled' "${label} remains disabled"
  contains_literal "$rc" 'oneshot' "${label} remains oneshot"
  assert_rc_lacks "$rc" 'LD_LIBRARY_PATH' "${label} LD_LIBRARY_PATH"
}

check_service_semantics() {
  local root="$1"
  local label="$2"

  assert_rc_has "${root}/vendor/etc/init/qseecomd.rc" 'on init' "${label} qseecomd init action"
  assert_rc_has "${root}/vendor/etc/init/qseecomd.rc" 'start vendor.qseecomd' "${label} qseecomd autostart"
  assert_rc_lacks "${root}/vendor/etc/init/qseecomd.rc" 'disabled' "${label} qseecomd disabled"
  assert_rc_lacks "${root}/vendor/etc/init/qseecomd.rc" 'oneshot' "${label} qseecomd oneshot"
  assert_rc_has "${root}/vendor/etc/init/qseecomd.rc" 'setenv LD_LIBRARY_PATH /vendor/lib64/rm11-d2k-compat:/vendor/lib64:/vendor/lib64/hw:/vendor/lib:/vendor/lib/hw:/system/lib64:/system/lib' "${label} qseecomd full compat LD path"

  assert_rc_has "${root}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'on init' "${label} onekeymint init action"
  assert_rc_has "${root}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'start vendor.keymint' "${label} onekeymint autostart"
  assert_rc_lacks "${root}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'disabled' "${label} onekeymint disabled"
  assert_rc_lacks "${root}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'oneshot' "${label} onekeymint oneshot"
  assert_rc_lacks "${root}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'LD_LIBRARY_PATH' "${label} onekeymint LD_LIBRARY_PATH"

  assert_rc_has "${root}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'on property:vendor.gatekeeper.is_security_level_spu=0' "${label} gatekeeper property enable trigger"
  assert_rc_has "${root}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'enable vendor.gatekeeper_default' "${label} gatekeeper enable"
  assert_rc_has "${root}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'disabled' "${label} gatekeeper starts disabled"
  assert_rc_lacks "${root}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'oneshot' "${label} gatekeeper oneshot"
  assert_rc_has "${root}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'setenv LD_LIBRARY_PATH /vendor/lib64/rm11-d2m-libcxx:/vendor/lib64:/vendor/lib64/hw:/vendor/lib:/vendor/lib/hw:/system/lib64:/system/lib' "${label} gatekeeper libc++ LD path"

  assert_rc_has "${root}/system/etc/init/keystore2.rc" 'on late-init' "${label} keystore2 late-init action"
  assert_rc_has "${root}/system/etc/init/keystore2.rc" 'start keystore2' "${label} keystore2 autostart"
  assert_rc_has "${root}/system/etc/init/keystore2.rc" 'service keystore2 /system/bin/keystore2 /tmp/misc/keystore' "${label} keystore2 TWRP binary path"
  assert_rc_lacks "${root}/system/etc/init/keystore2.rc" 'disabled' "${label} keystore2 disabled"
  assert_rc_lacks "${root}/system/etc/init/keystore2.rc" 'oneshot' "${label} keystore2 oneshot"
  assert_rc_has "${root}/system/etc/init/keystore2.rc" 'setenv LD_LIBRARY_PATH /vendor/lib64/rm11-d2m-libcxx:/system/lib64:/vendor/lib64:/system/lib:/vendor/lib' "${label} keystore2 libc++ LD path"

  assert_rc_has "${root}/vendor/etc/init/android.hardware.boot-service.qti.rc" 'interface aidl android.hardware.boot.IBootControl/default' "${label} boot HAL AIDL interface"
  assert_rc_lacks "${root}/vendor/etc/init/android.hardware.boot-service.qti.rc" 'disabled' "${label} boot HAL disabled"
  assert_rc_lacks "${root}/vendor/etc/init/android.hardware.boot-service.qti.rc" 'oneshot' "${label} boot HAL oneshot"
  assert_rc_has "${root}/vendor/etc/init/android.hardware.boot-service.qti.rc" 'setenv LD_LIBRARY_PATH /vendor/lib64/rm11-d2m-libcxx:/vendor/lib64:/vendor/lib64/hw:/vendor/lib:/vendor/lib/hw:/system/lib64:/system/lib' "${label} boot HAL libc++ LD path"

  check_strongbox_side_lane "${root}/vendor/etc/init/android.hardware.security.keymint-service-qti.rc" "${label} strongbox keymint-qti"
  check_strongbox_side_lane "${root}/vendor/etc/init/android.hardware.weaver-service.qti.rc" "${label} weaver"
  check_strongbox_side_lane "${root}/vendor/etc/init/android.hardware.secure_element.rc" "${label} secure element"
}

tmp_avb="$(mktemp)"
trap 'rm -f "$tmp_avb"' EXIT

need_cmd python3
need_cmd sha256sum
need_file "$IMAGE"
need_file "$AVBTOOL"
need_file "$UNPACK_SCRIPT"
need_file "${DEVICE_DIR}/AndroidProducts.mk"
need_file "${DEVICE_DIR}/BoardConfig.mk"
need_file "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2m.mk"
need_file "${DEVICE_DIR}/d2m/recovery/root/init.recovery.qcom.rc"
need_file "$TWRP_CPP"

[ ! -e "$UNPACK_DIR" ] || fail "unpack directory already exists: $UNPACK_DIR"

printf '===== D2M PREFLASH VERIFY =====\n'
printf 'image: %s\n' "$IMAGE"
printf 'fox_dir: %s\n' "$FOX_DIR"
printf 'unpack_dir: %s\n\n' "$UNPACK_DIR"

actual_bytes="$(stat -c '%s' "$IMAGE")"
[ "$actual_bytes" = "$EXPECTED_BYTES" ] || fail "image size mismatch: got ${actual_bytes}, expected ${EXPECTED_BYTES}"
pass "image size is ${EXPECTED_BYTES} bytes"

check_sha "$IMAGE" "$EXPECTED_SHA256" "frozen D2M image"

python3 "$AVBTOOL" info_image --image "$IMAGE" >"$tmp_avb"
grep -Fq "$EXPECTED_FINGERPRINT_PART" "$tmp_avb" || fail "AVB fingerprint does not contain ${EXPECTED_FINGERPRINT_PART}"
pass "AVB fingerprint contains ${EXPECTED_FINGERPRINT_PART}"

contains_literal "${DEVICE_DIR}/AndroidProducts.mk" '$(LOCAL_DIR)/orangefox_NX809J_codingbr_d2m.mk' "PRODUCT_MAKEFILES D2M entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2m-ap2a-eng' "COMMON_LUNCH_CHOICES D2M eng entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2m-ap2a-userdebug' "COMMON_LUNCH_CHOICES D2M userdebug entry"

if grep -E '^RM11_NO_DECRYPT_PRODUCTS.*orangefox_NX809J_codingbr_d2m' "${DEVICE_DIR}/BoardConfig.mk" >/dev/null; then
  fail "${PRODUCT} is listed in RM11_NO_DECRYPT_PRODUCTS"
fi
pass "${PRODUCT} is not in RM11_NO_DECRYPT_PRODUCTS"

d2m_block="$(sed -n '/ifeq ($(TARGET_PRODUCT),orangefox_NX809J_codingbr_d2m)/,/endif/p' "${DEVICE_DIR}/BoardConfig.mk")"
[ -n "$d2m_block" ] || fail "missing D2M TARGET_PRODUCT block in BoardConfig.mk"
for overlay in d2i d2k d2l d2m; do
  printf '%s\n' "$d2m_block" | grep -Fq "\$(DEVICE_PATH)/${overlay}" || fail "D2M TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/${overlay}"
done
if printf '%s\n' "$d2m_block" | grep -Fq '$(DEVICE_PATH)/d2h'; then
  fail "D2M TARGET_RECOVERY_DEVICE_DIRS includes D2H"
fi
pass "D2M TARGET_RECOVERY_DEVICE_DIRS includes d2i+d2k+d2l+d2m and excludes d2h"

SRC_ROOT="${DEVICE_DIR}/d2m/recovery/root"
reject_literal "$SRC_ROOT" 'sys.rm11.d2h.start_' "D2H trigger"
reject_literal "$SRC_ROOT" 'sys.rm11.d2j.start_' "D2J trigger"
reject_literal "$SRC_ROOT" 'sys.rm11.d2k.start_' "D2K trigger"
reject_literal "$SRC_ROOT" 'sys.rm11.d2l.start_' "D2L trigger"
reject_literal "$SRC_ROOT" 'ro.rm11.decrypt_candidate_d2h' "D2H marker"
reject_literal "$SRC_ROOT" 'ro.rm11.decrypt_candidate_d2k' "D2K marker"
reject_literal "$SRC_ROOT" 'ro.rm11.decrypt_candidate_d2l' "D2L marker"
reject_literal "$SRC_ROOT" 'import /init.recovery.wlan.rc' "Wi-Fi import"
[ ! -e "${SRC_ROOT}/init.recovery.wlan.rc" ] || fail "D2M source unexpectedly contains init.recovery.wlan.rc"
pass "D2M source has no init.recovery.wlan.rc"

contains_literal "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2m.mk" "$EXPECTED_MARKER" "D2M source property marker"
contains_literal "${SRC_ROOT}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "D2M source prepdecrypt.setpatch restore"
contains_literal "${SRC_ROOT}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "D2M source prepdecrypt.vendor trigger restore"

for trigger in \
  'sys.rm11.d2m.start_qseecomd' \
  'sys.rm11.d2m.start_keymint_qti' \
  'sys.rm11.d2m.start_onekeymint' \
  'sys.rm11.d2m.start_gatekeeper' \
  'sys.rm11.d2m.start_weaver' \
  'sys.rm11.d2m.start_secure_element' \
  'sys.rm11.d2m.start_keystore2'
do
  grep -R -Fq "$trigger" "$SRC_ROOT" 2>/dev/null || fail "D2M source is missing trigger ${trigger}"
  pass "D2M source contains ${trigger}"
done

check_sha "${SRC_ROOT}/system/bin/keystore2" "$EXPECTED_KEYSTORE2_SHA256" "D2M source TWRP keystore2"
check_sha "${SRC_ROOT}/vendor/lib64/rm11-d2m-libcxx/libc++.so" "$EXPECTED_LIBCXX_SHA256" "D2M source scoped libc++"
need_dir "${DEVICE_DIR}/d2k/recovery/root/vendor/lib64/rm11-d2k-compat"
check_sha "${DEVICE_DIR}/d2k/recovery/root/vendor/lib64/rm11-d2k-compat/libc++.so" "$EXPECTED_LIBCXX_SHA256" "D2K qsee compat libc++ source"
for lib in libbinder.so libbinder_ndk.so libbase.so libcutils.so libutils.so liblog.so libvndksupport.so libapexsupport.so; do
  need_file "${DEVICE_DIR}/d2k/recovery/root/vendor/lib64/rm11-d2k-compat/${lib}"
  pass "D2K qsee compat ${lib} source present"
done

check_service_semantics "$SRC_ROOT" "D2M source"

"$UNPACK_SCRIPT" "$IMAGE" "$UNPACK_DIR" >/dev/null
ROOT_DIR="${UNPACK_DIR}/ramdisk-root"
need_dir "$ROOT_DIR"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_MARKER}"
pass "unpacked ramdisk contains ${EXPECTED_MARKER}"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_TOUCH_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_TOUCH_MARKER}"
pass "unpacked ramdisk preserves ${EXPECTED_TOUCH_MARKER}"

need_file "${ROOT_DIR}/init.recovery.qcom.rc"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "unpacked D2M prepdecrypt.setpatch restore"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "unpacked D2M prepdecrypt.vendor trigger restore"
reject_literal "$ROOT_DIR" 'sys.rm11.d2h.start_' "unpacked D2H trigger"
reject_literal "$ROOT_DIR" 'sys.rm11.d2j.start_' "unpacked D2J trigger"
reject_literal "$ROOT_DIR" 'sys.rm11.d2k.start_' "unpacked D2K trigger"
reject_literal "$ROOT_DIR" 'sys.rm11.d2l.start_' "unpacked D2L trigger"
reject_literal "$ROOT_DIR" 'ro.rm11.decrypt_candidate_d2h' "unpacked D2H marker"
reject_literal "$ROOT_DIR" 'ro.rm11.decrypt_candidate_d2k' "unpacked D2K marker"
reject_literal "$ROOT_DIR" 'ro.rm11.decrypt_candidate_d2l' "unpacked D2L marker"

for trigger in \
  'sys.rm11.d2m.start_qseecomd' \
  'sys.rm11.d2m.start_keymint_qti' \
  'sys.rm11.d2m.start_onekeymint' \
  'sys.rm11.d2m.start_gatekeeper' \
  'sys.rm11.d2m.start_weaver' \
  'sys.rm11.d2m.start_secure_element' \
  'sys.rm11.d2m.start_keystore2'
do
  grep -R -Fq "$trigger" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing trigger ${trigger}"
  pass "unpacked ramdisk contains ${trigger}"
done

[ ! -e "${ROOT_DIR}/init.recovery.wlan.rc" ] || fail "D2M ramdisk unexpectedly contains init.recovery.wlan.rc"
pass "D2M ramdisk does not contain init.recovery.wlan.rc"
if grep -R -Fq 'import /init.recovery.wlan.rc' "${ROOT_DIR}/init.recovery.qcom.rc" 2>/dev/null; then
  fail "D2M init.recovery.qcom.rc imports Wi-Fi lane"
fi
pass "D2M init.recovery.qcom.rc does not import Wi-Fi lane"

check_sha "${ROOT_DIR}/system/bin/keystore2" "$EXPECTED_KEYSTORE2_SHA256" "unpacked TWRP keystore2"
check_sha "${ROOT_DIR}/vendor/lib64/rm11-d2m-libcxx/libc++.so" "$EXPECTED_LIBCXX_SHA256" "unpacked scoped libc++"
check_sha "${ROOT_DIR}/vendor/lib64/rm11-d2k-compat/libc++.so" "$EXPECTED_LIBCXX_SHA256" "unpacked qsee compat libc++"
for lib in libbinder.so libbinder_ndk.so libbase.so libcutils.so libutils.so liblog.so libvndksupport.so libapexsupport.so; do
  need_file "${ROOT_DIR}/vendor/lib64/rm11-d2k-compat/${lib}"
  pass "unpacked qsee compat ${lib} present"
done

check_service_semantics "$ROOT_DIR" "unpacked D2M"

if find "$ROOT_DIR" -name 'spss1*.mdt' -o -name 'spss1*.b*' | grep -q .; then
  fail "D2M ramdisk unexpectedly stages SPSS firmware"
fi
pass "D2M ramdisk does not stage SPSS firmware"

need_file "${ROOT_DIR}/system/etc/vintf/manifest.xml"
need_file "${ROOT_DIR}/vendor/etc/vintf/manifest.xml"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" 'android.hardware.gatekeeper' "unpacked gatekeeper VINTF declaration"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" 'android.hardware.weaver' "unpacked weaver VINTF declaration"

contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "1");' "OrangeFox crypto-enabled runtime property path"
contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "0");' "OrangeFox crypto-disabled runtime property path"
pass "crypto expectation is provable: D2M is outside RM11_NO_DECRYPT_PRODUCTS, so BoardConfig selects the TW_INCLUDE_CRYPTO lane"

printf '\n===== AVB FINGERPRINT =====\n'
grep -F 'com.android.build.recovery.fingerprint' "$tmp_avb" || true

printf '\nRESULT: PASS. D2M preflash gate passed. This script does not flash anything.\n'
