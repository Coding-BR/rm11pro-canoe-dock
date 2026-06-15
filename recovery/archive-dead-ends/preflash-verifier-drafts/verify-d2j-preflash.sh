#!/usr/bin/env bash
set -euo pipefail

# Read-only D2J preflash gate for RM11 Pro / NX809J.
# D2J keeps the D2I prepdecrypt baseline and probes Android 16 crypto
# services with scoped compatibility libraries. It must not replace global
# recovery Binder/VINTF libraries.

FOX_DIR="${FOX_DIR:-/home/richtofen/.android/repositories/MainAssets/fox_14.1}"
ARTIFACT_DIR="${ARTIFACT_DIR:-/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2j-scoped-a16-binder-vintf-probe}"
IMAGE="${IMAGE:-${ARTIFACT_DIR}/OrangeFox-R12.0-Unofficial-NX809J-d2j-scoped-a16-binder-vintf-probe.img}"
EXPECTED_BYTES="${EXPECTED_BYTES:-104857600}"
EXPECTED_SHA256="${EXPECTED_SHA256:-63bc25d2eab08421f17add159fa872742cf6c6c0a69435121704a8065dce5080}"
EXPECTED_FINGERPRINT_PART="${EXPECTED_FINGERPRINT_PART:-orangefox_NX809J_codingbr_d2j}"
EXPECTED_MARKER="${EXPECTED_MARKER:-ro.rm11.decrypt_candidate_d2j=d2j-scoped-a16-binder-vintf-probe}"
EXPECTED_TOUCH_MARKER="${EXPECTED_TOUCH_MARKER:-ro.rm11.touch_candidate_d1t3=d1t3-minuitwrp-touch-normalization}"
TWRP_BINDER_NDK_SHA256="${TWRP_BINDER_NDK_SHA256:-d238c5bfb2ffb56af8631fb9e23dcc343e00e9b7179e18231929f2d4f67175a3}"
TWRP_LIBVINTF_SHA256="${TWRP_LIBVINTF_SHA256:-e3d35b5b781f85df704d48f8eb14c4e28a2ea9de4063041c0eb10832dea5c8b9}"
STOCK_A16_BINDER_NDK_SHA256="${STOCK_A16_BINDER_NDK_SHA256:-64a052167ee3293943ddb6ef0cd75a5a894a6b502b6a560e2524679d6916863a}"
STOCK_A16_LIBCXX_SHA256="${STOCK_A16_LIBCXX_SHA256:-2267f93b8b3c9d1967f1833d5f71c7312213c43bb291250cf772800763037fb9}"
STOCK_A16_BINDER_SHA256="${STOCK_A16_BINDER_SHA256:-034661e097f5b2674287ef3dac3abe70a4d89e0517a5b2fd1ede43cb78291e01}"

PRODUCT="orangefox_NX809J_codingbr_d2j"
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
  pass "$label found in $file"
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

tmp_avb="$(mktemp)"
trap 'rm -f "$tmp_avb"' EXIT

need_cmd python3
need_cmd sha256sum
need_file "$IMAGE"
need_file "$AVBTOOL"
need_file "$UNPACK_SCRIPT"
need_file "${DEVICE_DIR}/AndroidProducts.mk"
need_file "${DEVICE_DIR}/BoardConfig.mk"
need_file "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2j.mk"
need_file "${DEVICE_DIR}/d2j/recovery/root/init.recovery.qcom.rc"
need_file "$TWRP_CPP"

[ ! -e "$UNPACK_DIR" ] || fail "unpack directory already exists: $UNPACK_DIR"

printf '===== D2J PREFLASH VERIFY =====\n'
printf 'image: %s\n' "$IMAGE"
printf 'fox_dir: %s\n' "$FOX_DIR"
printf 'unpack_dir: %s\n\n' "$UNPACK_DIR"

actual_bytes="$(stat -c '%s' "$IMAGE")"
[ "$actual_bytes" = "$EXPECTED_BYTES" ] || fail "image size mismatch: got ${actual_bytes}, expected ${EXPECTED_BYTES}"
pass "image size is ${EXPECTED_BYTES} bytes"

check_sha "$IMAGE" "$EXPECTED_SHA256" "frozen D2J image"

python3 "$AVBTOOL" info_image --image "$IMAGE" >"$tmp_avb"
grep -Fq "$EXPECTED_FINGERPRINT_PART" "$tmp_avb" || fail "AVB fingerprint does not contain ${EXPECTED_FINGERPRINT_PART}"
pass "AVB fingerprint contains ${EXPECTED_FINGERPRINT_PART}"

contains_literal "${DEVICE_DIR}/AndroidProducts.mk" '$(LOCAL_DIR)/orangefox_NX809J_codingbr_d2j.mk' "PRODUCT_MAKEFILES D2J entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2j-ap2a-eng' "COMMON_LUNCH_CHOICES D2J eng entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2j-ap2a-userdebug' "COMMON_LUNCH_CHOICES D2J userdebug entry"

if grep -E '^RM11_NO_DECRYPT_PRODUCTS.*orangefox_NX809J_codingbr_d2j' "${DEVICE_DIR}/BoardConfig.mk" >/dev/null; then
  fail "${PRODUCT} is listed in RM11_NO_DECRYPT_PRODUCTS"
fi
pass "${PRODUCT} is not in RM11_NO_DECRYPT_PRODUCTS"

d2j_block="$(sed -n '/ifeq ($(TARGET_PRODUCT),orangefox_NX809J_codingbr_d2j)/,/endif/p' "${DEVICE_DIR}/BoardConfig.mk")"
printf '%s\n' "$d2j_block" | grep -Fq '$(DEVICE_PATH)/d2i' || fail "D2J TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2i"
printf '%s\n' "$d2j_block" | grep -Fq '$(DEVICE_PATH)/d2j' || fail "D2J TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2j"
if printf '%s\n' "$d2j_block" | grep -Fq '$(DEVICE_PATH)/d2h'; then
  fail "D2J TARGET_RECOVERY_DEVICE_DIRS includes D2H"
fi
pass "D2J TARGET_RECOVERY_DEVICE_DIRS includes d2i+d2j and excludes d2h"

if [ -e "${DEVICE_DIR}/d2j/recovery/root/system/lib64/libbinder_ndk.so" ] || [ -e "${DEVICE_DIR}/d2j/recovery/root/system/lib64/libvintf.so" ]; then
  fail "D2J source overlay contains global system lib64 Binder/VINTF replacement"
fi
pass "D2J source overlay has no global system lib64 Binder/VINTF replacement"

contains_literal "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2j.mk" "$EXPECTED_MARKER" "D2J source property marker"
contains_literal "${DEVICE_DIR}/d2j/recovery/root/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "D2J prepdecrypt.setpatch restore"
contains_literal "${DEVICE_DIR}/d2j/recovery/root/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "D2J prepdecrypt.vendor trigger restore"
contains_literal "${DEVICE_DIR}/d2j/recovery/root/system/etc/init/keystore2.rc" 'interface aidl android.system.keystore2.IKeystoreService/default' "D2J keystore2 lazy AIDL interface"

"$UNPACK_SCRIPT" "$IMAGE" "$UNPACK_DIR" >/dev/null
ROOT_DIR="${UNPACK_DIR}/ramdisk-root"
need_dir "$ROOT_DIR"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_MARKER}"
pass "unpacked ramdisk contains ${EXPECTED_MARKER}"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_TOUCH_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_TOUCH_MARKER}"
pass "unpacked ramdisk preserves ${EXPECTED_TOUCH_MARKER}"

need_file "${ROOT_DIR}/init.recovery.qcom.rc"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "unpacked D2J prepdecrypt.setpatch restore"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "unpacked D2J prepdecrypt.vendor trigger restore"

for trigger in \
  'sys.rm11.d2j.start_qseecomd' \
  'sys.rm11.d2j.start_keymint_qti' \
  'sys.rm11.d2j.start_onekeymint' \
  'sys.rm11.d2j.start_gatekeeper' \
  'sys.rm11.d2j.start_weaver' \
  'sys.rm11.d2j.start_secure_element' \
  'sys.rm11.d2j.start_keystore2'
do
  grep -R -Fq "$trigger" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing trigger ${trigger}"
  pass "unpacked ramdisk contains ${trigger}"
done

if grep -R -Fq 'sys.rm11.d2h.start_' "$ROOT_DIR" 2>/dev/null; then
  fail "unpacked D2J ramdisk contains D2H trigger names"
fi
pass "unpacked D2J ramdisk does not contain D2H trigger names"

if [ -e "${ROOT_DIR}/init.recovery.wlan.rc" ]; then
  fail "D2J ramdisk unexpectedly contains init.recovery.wlan.rc"
fi
pass "D2J ramdisk does not contain init.recovery.wlan.rc"

if grep -R -Fq 'import /init.recovery.wlan.rc' "${ROOT_DIR}/init.recovery.qcom.rc" 2>/dev/null; then
  fail "D2J init.recovery.qcom.rc imports Wi-Fi lane"
fi
pass "D2J init.recovery.qcom.rc does not import Wi-Fi lane"

need_file "${ROOT_DIR}/system/etc/init/keystore2.rc"
contains_literal "${ROOT_DIR}/system/etc/init/keystore2.rc" 'interface aidl android.system.keystore2.IKeystoreService/default' "unpacked keystore2 lazy AIDL interface"
contains_literal "${ROOT_DIR}/system/etc/init/keystore2.rc" 'disabled' "unpacked keystore2 remains disabled"
contains_literal "${ROOT_DIR}/system/etc/init/keystore2.rc" 'oneshot' "unpacked keystore2 remains oneshot"

need_file "${ROOT_DIR}/system/etc/vintf/manifest.xml"
contains_literal "${ROOT_DIR}/system/etc/vintf/manifest.xml" '<manifest version="1.0" type="framework">' "unpacked framework VINTF downlevel"
need_file "${ROOT_DIR}/vendor/etc/vintf/manifest.xml"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" '<manifest version="1.0" type="device">' "unpacked vendor VINTF downlevel"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" 'android.hardware.gatekeeper' "unpacked gatekeeper VINTF declaration"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest.xml" 'android.hardware.weaver' "unpacked weaver VINTF declaration"
need_file "${ROOT_DIR}/vendor/etc/vintf/manifest/android.hardware.secure_element-service-aidl.xml"
contains_literal "${ROOT_DIR}/vendor/etc/vintf/manifest/android.hardware.secure_element-service-aidl.xml" '<manifest version="1.0" type="device">' "unpacked secure element VINTF downlevel"

for rc in \
  "${ROOT_DIR}/vendor/etc/init/qseecomd.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.security.keymint-service-qti.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.weaver-service.qti.rc" \
  "${ROOT_DIR}/vendor/etc/init/android.hardware.secure_element.rc"
do
  need_file "$rc"
  contains_literal "$rc" 'disabled' "$(basename "$rc") disabled"
  contains_literal "$rc" 'oneshot' "$(basename "$rc") oneshot"
  contains_literal "$rc" '/vendor/lib64/rm11-d2j-compat' "$(basename "$rc") D2J compat LD_LIBRARY_PATH"
done

need_file "${ROOT_DIR}/system/lib64/libbinder_ndk.so"
need_file "${ROOT_DIR}/system/lib64/libvintf.so"

ramdisk_binder_sha="$(sha256sum "${ROOT_DIR}/system/lib64/libbinder_ndk.so" | awk '{print $1}')"
[ "$ramdisk_binder_sha" != "$TWRP_BINDER_NDK_SHA256" ] || fail "unpacked D2J global libbinder_ndk.so matches D2H/TWRP replacement"
[ "$ramdisk_binder_sha" != "$STOCK_A16_BINDER_NDK_SHA256" ] || fail "unpacked D2J global libbinder_ndk.so was replaced by stock Android 16"
pass "unpacked D2J global libbinder_ndk.so is unchanged from D2I-style recovery userspace"

ramdisk_vintf_sha="$(sha256sum "${ROOT_DIR}/system/lib64/libvintf.so" | awk '{print $1}')"
[ "$ramdisk_vintf_sha" != "$TWRP_LIBVINTF_SHA256" ] || fail "unpacked D2J global libvintf.so matches D2H/TWRP replacement"
pass "unpacked D2J global libvintf.so is not the D2H/TWRP replacement"

COMPAT_DIR="${ROOT_DIR}/vendor/lib64/rm11-d2j-compat"
need_dir "$COMPAT_DIR"
check_sha "${COMPAT_DIR}/libbinder_ndk.so" "$STOCK_A16_BINDER_NDK_SHA256" "scoped stock Android 16 libbinder_ndk.so"
check_sha "${COMPAT_DIR}/libbinder.so" "$STOCK_A16_BINDER_SHA256" "scoped stock Android 16 libbinder.so"
check_sha "${COMPAT_DIR}/libc++.so" "$STOCK_A16_LIBCXX_SHA256" "scoped stock Android 16 libc++.so"

contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "1");' "OrangeFox crypto-enabled runtime property path"
contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "0");' "OrangeFox crypto-disabled runtime property path"
pass "crypto expectation is provable: D2J is outside RM11_NO_DECRYPT_PRODUCTS, so BoardConfig selects the TW_INCLUDE_CRYPTO lane"

printf '\n===== AVB FINGERPRINT =====\n'
grep -F 'com.android.build.recovery.fingerprint' "$tmp_avb" || true

printf '\nRESULT: PASS. D2J preflash gate passed. This script does not flash anything.\n'
