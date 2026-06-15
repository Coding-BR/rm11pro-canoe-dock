#!/usr/bin/env bash
set -euo pipefail

# Read-only D2L preflash gate for RM11 Pro / NX809J.
# D2L keeps crypto enabled, preserves the D1T3 touch/UI baseline, restores the
# TWRP-stable security core, and intentionally leaves Wi-Fi/SPSS chasing out.

FOX_DIR="${FOX_DIR:-/home/richtofen/.android/repositories/MainAssets/fox_14.1}"
ARTIFACT_DIR="${ARTIFACT_DIR:-/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2l-twrp-stable-security-core}"
IMAGE="${IMAGE:-${ARTIFACT_DIR}/OrangeFox-R12.0-Unofficial-NX809J-d2l-twrp-stable-security-core.img}"
EXPECTED_BYTES="${EXPECTED_BYTES:-104857600}"
EXPECTED_SHA256="${EXPECTED_SHA256:-91db95707f1fba2e6733c57ed5752d2ceff8b35b6d52aef85056642095baa081}"
EXPECTED_FINGERPRINT_PART="${EXPECTED_FINGERPRINT_PART:-orangefox_NX809J_codingbr_d2l}"
EXPECTED_MARKER="${EXPECTED_MARKER:-ro.rm11.decrypt_candidate_d2l=d2l-twrp-stable-security-core}"
EXPECTED_TOUCH_MARKER="${EXPECTED_TOUCH_MARKER:-ro.rm11.touch_candidate_d1t3=d1t3-minuitwrp-touch-normalization}"

PRODUCT="orangefox_NX809J_codingbr_d2l"
DEVICE_DIR="${FOX_DIR}/device/zte/sm88XX"
AVBTOOL="${FOX_DIR}/external/avb/avbtool.py"
TWRP_CPP="${FOX_DIR}/bootable/recovery/twrp.cpp"
UNPACK_SCRIPT="${UNPACK_SCRIPT:-/home/richtofen/.android/repositories/rm11pro-canoe-dock/scripts/recovery/unpack-android-boot-lz4.sh}"
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

tmp_avb="$(mktemp)"
trap 'rm -f "$tmp_avb"' EXIT

need_cmd python3
need_cmd sha256sum
need_file "$IMAGE"
need_file "$AVBTOOL"
need_file "$UNPACK_SCRIPT"
need_file "${DEVICE_DIR}/AndroidProducts.mk"
need_file "${DEVICE_DIR}/BoardConfig.mk"
need_file "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2l.mk"
need_file "${DEVICE_DIR}/d2l/recovery/root/init.recovery.qcom.rc"
need_file "$TWRP_CPP"

[ ! -e "$UNPACK_DIR" ] || fail "unpack directory already exists: $UNPACK_DIR"

printf '===== D2L PREFLASH VERIFY =====\n'
printf 'image: %s\n' "$IMAGE"
printf 'fox_dir: %s\n' "$FOX_DIR"
printf 'unpack_dir: %s\n\n' "$UNPACK_DIR"

actual_bytes="$(stat -c '%s' "$IMAGE")"
[ "$actual_bytes" = "$EXPECTED_BYTES" ] || fail "image size mismatch: got ${actual_bytes}, expected ${EXPECTED_BYTES}"
pass "image size is ${EXPECTED_BYTES} bytes"

check_sha "$IMAGE" "$EXPECTED_SHA256" "frozen D2L image"

python3 "$AVBTOOL" info_image --image "$IMAGE" >"$tmp_avb"
grep -Fq "$EXPECTED_FINGERPRINT_PART" "$tmp_avb" || fail "AVB fingerprint does not contain ${EXPECTED_FINGERPRINT_PART}"
pass "AVB fingerprint contains ${EXPECTED_FINGERPRINT_PART}"

contains_literal "${DEVICE_DIR}/AndroidProducts.mk" '$(LOCAL_DIR)/orangefox_NX809J_codingbr_d2l.mk' "PRODUCT_MAKEFILES D2L entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2l-ap2a-eng' "COMMON_LUNCH_CHOICES D2L eng entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2l-ap2a-userdebug' "COMMON_LUNCH_CHOICES D2L userdebug entry"

if grep -E '^RM11_NO_DECRYPT_PRODUCTS.*orangefox_NX809J_codingbr_d2l' "${DEVICE_DIR}/BoardConfig.mk" >/dev/null; then
  fail "${PRODUCT} is listed in RM11_NO_DECRYPT_PRODUCTS"
fi
pass "${PRODUCT} is not in RM11_NO_DECRYPT_PRODUCTS"

d2l_block="$(sed -n '/ifeq ($(TARGET_PRODUCT),orangefox_NX809J_codingbr_d2l)/,/endif/p' "${DEVICE_DIR}/BoardConfig.mk")"
[ -n "$d2l_block" ] || fail "missing D2L TARGET_PRODUCT block in BoardConfig.mk"
printf '%s\n' "$d2l_block" | grep -Fq '$(DEVICE_PATH)/d2i' || fail "D2L TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2i"
printf '%s\n' "$d2l_block" | grep -Fq '$(DEVICE_PATH)/d2k' || fail "D2L TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2k"
printf '%s\n' "$d2l_block" | grep -Fq '$(DEVICE_PATH)/d2l' || fail "D2L TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2l"
if printf '%s\n' "$d2l_block" | grep -Fq '$(DEVICE_PATH)/d2h'; then
  fail "D2L TARGET_RECOVERY_DEVICE_DIRS includes D2H"
fi
pass "D2L TARGET_RECOVERY_DEVICE_DIRS includes d2i+d2k+d2l and excludes d2h"

SRC_ROOT="${DEVICE_DIR}/d2l/recovery/root"
reject_literal "$SRC_ROOT" 'sys.rm11.d2h.start_' "D2H trigger"
reject_literal "$SRC_ROOT" 'sys.rm11.d2j.start_' "D2J trigger"
reject_literal "$SRC_ROOT" 'sys.rm11.d2k.start_' "D2K trigger"
reject_literal "$SRC_ROOT" 'ro.rm11.decrypt_candidate_d2k' "D2K marker"
reject_literal "$SRC_ROOT" 'import /init.recovery.wlan.rc' "Wi-Fi import"
[ ! -e "${SRC_ROOT}/init.recovery.wlan.rc" ] || fail "D2L source unexpectedly contains init.recovery.wlan.rc"
pass "D2L source has no init.recovery.wlan.rc"

contains_literal "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2l.mk" "$EXPECTED_MARKER" "D2L source property marker"
contains_literal "${SRC_ROOT}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "D2L source prepdecrypt.setpatch restore"
contains_literal "${SRC_ROOT}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "D2L source prepdecrypt.vendor trigger restore"

for trigger in \
  'sys.rm11.d2l.start_qseecomd' \
  'sys.rm11.d2l.start_keymint_qti' \
  'sys.rm11.d2l.start_onekeymint' \
  'sys.rm11.d2l.start_gatekeeper' \
  'sys.rm11.d2l.start_weaver' \
  'sys.rm11.d2l.start_secure_element' \
  'sys.rm11.d2l.start_keystore2'
do
  grep -R -Fq "$trigger" "$SRC_ROOT" 2>/dev/null || fail "D2L source is missing trigger ${trigger}"
  pass "D2L source contains ${trigger}"
done

assert_rc_has "${SRC_ROOT}/vendor/etc/init/qseecomd.rc" 'on init' "D2L source qseecomd init action"
assert_rc_has "${SRC_ROOT}/vendor/etc/init/qseecomd.rc" 'start vendor.qseecomd' "D2L source qseecomd autostart"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/qseecomd.rc" 'disabled' "D2L source qseecomd disabled"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/qseecomd.rc" 'oneshot' "D2L source qseecomd oneshot"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/qseecomd.rc" 'LD_LIBRARY_PATH' "D2L source qseecomd LD_LIBRARY_PATH"

assert_rc_has "${SRC_ROOT}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'on init' "D2L source onekeymint init action"
assert_rc_has "${SRC_ROOT}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'start vendor.keymint' "D2L source onekeymint autostart"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'disabled' "D2L source onekeymint disabled"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'oneshot' "D2L source onekeymint oneshot"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'LD_LIBRARY_PATH' "D2L source onekeymint LD_LIBRARY_PATH"

assert_rc_has "${SRC_ROOT}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'on property:vendor.gatekeeper.is_security_level_spu=0' "D2L source gatekeeper property enable trigger"
assert_rc_has "${SRC_ROOT}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'enable vendor.gatekeeper_default' "D2L source gatekeeper enable"
assert_rc_has "${SRC_ROOT}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'disabled' "D2L source gatekeeper starts disabled"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'oneshot' "D2L source gatekeeper oneshot"
assert_rc_lacks "${SRC_ROOT}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'LD_LIBRARY_PATH' "D2L source gatekeeper LD_LIBRARY_PATH"

assert_rc_has "${SRC_ROOT}/system/etc/init/keystore2.rc" 'on late-init' "D2L source keystore2 late-init action"
assert_rc_has "${SRC_ROOT}/system/etc/init/keystore2.rc" 'start keystore2' "D2L source keystore2 autostart"
assert_rc_lacks "${SRC_ROOT}/system/etc/init/keystore2.rc" 'disabled' "D2L source keystore2 disabled"
assert_rc_lacks "${SRC_ROOT}/system/etc/init/keystore2.rc" 'oneshot' "D2L source keystore2 oneshot"

for rc in \
  "${SRC_ROOT}/vendor/etc/init/android.hardware.security.keymint-service-qti.rc" \
  "${SRC_ROOT}/vendor/etc/init/android.hardware.weaver-service.qti.rc" \
  "${SRC_ROOT}/vendor/etc/init/android.hardware.secure_element.rc"
do
  need_file "$rc"
  contains_literal "$rc" 'disabled' "$(basename "$rc") source remains disabled"
  contains_literal "$rc" 'oneshot' "$(basename "$rc") source remains oneshot"
  assert_rc_lacks "$rc" 'LD_LIBRARY_PATH' "$(basename "$rc") source LD_LIBRARY_PATH"
done

"$UNPACK_SCRIPT" "$IMAGE" "$UNPACK_DIR" >/dev/null
ROOT_DIR="${UNPACK_DIR}/ramdisk-root"
need_dir "$ROOT_DIR"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_MARKER}"
pass "unpacked ramdisk contains ${EXPECTED_MARKER}"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_TOUCH_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_TOUCH_MARKER}"
pass "unpacked ramdisk preserves ${EXPECTED_TOUCH_MARKER}"

need_file "${ROOT_DIR}/init.recovery.qcom.rc"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "unpacked D2L prepdecrypt.setpatch restore"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "unpacked D2L prepdecrypt.vendor trigger restore"
reject_literal "$ROOT_DIR" 'sys.rm11.d2h.start_' "unpacked D2H trigger"
reject_literal "$ROOT_DIR" 'sys.rm11.d2j.start_' "unpacked D2J trigger"
reject_literal "$ROOT_DIR" 'sys.rm11.d2k.start_' "unpacked D2K trigger"
reject_literal "$ROOT_DIR" 'ro.rm11.decrypt_candidate_d2k' "unpacked D2K marker"

for trigger in \
  'sys.rm11.d2l.start_qseecomd' \
  'sys.rm11.d2l.start_keymint_qti' \
  'sys.rm11.d2l.start_onekeymint' \
  'sys.rm11.d2l.start_gatekeeper' \
  'sys.rm11.d2l.start_weaver' \
  'sys.rm11.d2l.start_secure_element' \
  'sys.rm11.d2l.start_keystore2'
do
  grep -R -Fq "$trigger" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing trigger ${trigger}"
  pass "unpacked ramdisk contains ${trigger}"
done

[ ! -e "${ROOT_DIR}/init.recovery.wlan.rc" ] || fail "D2L ramdisk unexpectedly contains init.recovery.wlan.rc"
pass "D2L ramdisk does not contain init.recovery.wlan.rc"
if grep -R -Fq 'import /init.recovery.wlan.rc' "${ROOT_DIR}/init.recovery.qcom.rc" 2>/dev/null; then
  fail "D2L init.recovery.qcom.rc imports Wi-Fi lane"
fi
pass "D2L init.recovery.qcom.rc does not import Wi-Fi lane"

assert_rc_has "${ROOT_DIR}/vendor/etc/init/qseecomd.rc" 'on init' "unpacked qseecomd init action"
assert_rc_has "${ROOT_DIR}/vendor/etc/init/qseecomd.rc" 'start vendor.qseecomd' "unpacked qseecomd autostart"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/qseecomd.rc" 'disabled' "unpacked qseecomd disabled"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/qseecomd.rc" 'oneshot' "unpacked qseecomd oneshot"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/qseecomd.rc" 'LD_LIBRARY_PATH' "unpacked qseecomd LD_LIBRARY_PATH"

assert_rc_has "${ROOT_DIR}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'on init' "unpacked onekeymint init action"
assert_rc_has "${ROOT_DIR}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'start vendor.keymint' "unpacked onekeymint autostart"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'disabled' "unpacked onekeymint disabled"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'oneshot' "unpacked onekeymint oneshot"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" 'LD_LIBRARY_PATH' "unpacked onekeymint LD_LIBRARY_PATH"

assert_rc_has "${ROOT_DIR}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'on property:vendor.gatekeeper.is_security_level_spu=0' "unpacked gatekeeper property enable trigger"
assert_rc_has "${ROOT_DIR}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'enable vendor.gatekeeper_default' "unpacked gatekeeper enable"
assert_rc_has "${ROOT_DIR}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'disabled' "unpacked gatekeeper starts disabled"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'oneshot' "unpacked gatekeeper oneshot"
assert_rc_lacks "${ROOT_DIR}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" 'LD_LIBRARY_PATH' "unpacked gatekeeper LD_LIBRARY_PATH"

assert_rc_has "${ROOT_DIR}/system/etc/init/keystore2.rc" 'on late-init' "unpacked keystore2 late-init action"
assert_rc_has "${ROOT_DIR}/system/etc/init/keystore2.rc" 'start keystore2' "unpacked keystore2 autostart"
assert_rc_lacks "${ROOT_DIR}/system/etc/init/keystore2.rc" 'disabled' "unpacked keystore2 disabled"
assert_rc_lacks "${ROOT_DIR}/system/etc/init/keystore2.rc" 'oneshot' "unpacked keystore2 oneshot"

for rc in \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.security.keymint-service-qti.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.weaver-service.qti.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.secure_element.rc"
do
  need_file "$rc"
  contains_literal "$rc" 'disabled' "$(basename "$rc") unpacked remains disabled"
  contains_literal "$rc" 'oneshot' "$(basename "$rc") unpacked remains oneshot"
  assert_rc_lacks "$rc" 'LD_LIBRARY_PATH' "$(basename "$rc") unpacked LD_LIBRARY_PATH"
done

if find "$ROOT_DIR" -name 'spss1*.mdt' -o -name 'spss1*.b*' | grep -q .; then
  fail "D2L ramdisk unexpectedly stages SPSS firmware"
fi
pass "D2L ramdisk does not stage SPSS firmware"

need_file "${ROOT_DIR}/system/etc/vintf/manifest.xml"
need_file "${ROOT_DIR}/vendor/etc/vintf/manifest.xml"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" 'android.hardware.gatekeeper' "unpacked gatekeeper VINTF declaration"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" 'android.hardware.weaver' "unpacked weaver VINTF declaration"

contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "1");' "OrangeFox crypto-enabled runtime property path"
contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "0");' "OrangeFox crypto-disabled runtime property path"
pass "crypto expectation is provable: D2L is outside RM11_NO_DECRYPT_PRODUCTS, so BoardConfig selects the TW_INCLUDE_CRYPTO lane"

printf '\n===== AVB FINGERPRINT =====\n'
grep -F 'com.android.build.recovery.fingerprint' "$tmp_avb" || true

printf '\nRESULT: PASS. D2L preflash gate passed. This script does not flash anything.\n'
