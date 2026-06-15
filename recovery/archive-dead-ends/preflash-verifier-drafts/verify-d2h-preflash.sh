#!/usr/bin/env bash
set -euo pipefail

# Read-only D2H preflash gate for RM11 Pro / NX809J.
# It verifies the frozen image identity and unpacks the image into a new
# timestamped directory before checking D2H ramdisk semantics.

FOX_DIR="${FOX_DIR:-/home/richtofen/.android/repositories/MainAssets/fox_14.1}"
ARTIFACT_DIR="${ARTIFACT_DIR:-/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2h-android16-binder-vintf-probe}"
IMAGE="${IMAGE:-${ARTIFACT_DIR}/OrangeFox-R12.0-Unofficial-NX809J-d2h-android16-binder-vintf-probe.img}"
EXPECTED_BYTES="${EXPECTED_BYTES:-104857600}"
EXPECTED_SHA256="${EXPECTED_SHA256:-07886e1fb8e9757329989ceef36358d869d74aac828590a47892fb1e06f8167f}"
EXPECTED_FINGERPRINT_PART="${EXPECTED_FINGERPRINT_PART:-orangefox_NX809J_codingbr_d2h}"
EXPECTED_MARKER="${EXPECTED_MARKER:-ro.rm11.decrypt_candidate_d2h=d2h-android16-binder-vintf-probe}"
EXPECTED_TOUCH_MARKER="${EXPECTED_TOUCH_MARKER:-ro.rm11.touch_candidate_d1t3=d1t3-minuitwrp-touch-normalization}"
EXPECTED_BINDER_NDK_SHA256="${EXPECTED_BINDER_NDK_SHA256:-d238c5bfb2ffb56af8631fb9e23dcc343e00e9b7179e18231929f2d4f67175a3}"
EXPECTED_LIBVINTF_SHA256="${EXPECTED_LIBVINTF_SHA256:-e3d35b5b781f85df704d48f8eb14c4e28a2ea9de4063041c0eb10832dea5c8b9}"

PRODUCT="orangefox_NX809J_codingbr_d2h"
DEVICE_DIR="${FOX_DIR}/device/zte/sm88XX"
AVBTOOL="${FOX_DIR}/external/avb/avbtool.py"
TWRP_CPP="${FOX_DIR}/bootable/recovery/twrp.cpp"
UNPACK_SCRIPT="${UNPACK_SCRIPT:-/home/richtofen/.android/repositories/rm11pro-canoe-dock/scripts/recovery/unpack-android-boot-lz4.sh}"
UNPACK_DIR="${UNPACK_DIR:-${ARTIFACT_DIR}/verify-unpack-$(date +%Y%m%d-%H%M%S)}"
READELF="${READELF:-/usr/bin/readelf}"

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

readelf_contains() {
  local mode="$1"
  local file="$2"
  local text="$3"
  local label="$4"
  local out
  out="$("$READELF" "$mode" "$file")" || fail "readelf ${mode} failed for ${file}"
  grep -Fq "$text" <<<"$out" || fail "$label"
}

tmp_avb="$(mktemp)"
trap 'rm -f "$tmp_avb"' EXIT

need_cmd python3
need_cmd sha256sum
need_file "$IMAGE"
need_file "$AVBTOOL"
need_file "$UNPACK_SCRIPT"
need_file "$READELF"
need_file "${DEVICE_DIR}/AndroidProducts.mk"
need_file "${DEVICE_DIR}/BoardConfig.mk"
need_file "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2h.mk"
need_file "${DEVICE_DIR}/d2h/recovery/root/init.recovery.qcom.rc"
need_file "${DEVICE_DIR}/d2h/recovery/root/system/lib64/libbinder_ndk.so"
need_file "${DEVICE_DIR}/d2h/recovery/root/system/lib64/libvintf.so"
need_file "$TWRP_CPP"

[ ! -e "$UNPACK_DIR" ] || fail "unpack directory already exists: $UNPACK_DIR"

printf '===== D2H PREFLASH VERIFY =====\n'
printf 'image: %s\n' "$IMAGE"
printf 'fox_dir: %s\n' "$FOX_DIR"
printf 'unpack_dir: %s\n\n' "$UNPACK_DIR"

actual_bytes="$(stat -c '%s' "$IMAGE")"
[ "$actual_bytes" = "$EXPECTED_BYTES" ] || fail "image size mismatch: got ${actual_bytes}, expected ${EXPECTED_BYTES}"
pass "image size is ${EXPECTED_BYTES} bytes"

actual_sha="$(sha256sum "$IMAGE" | awk '{print $1}')"
[ "$actual_sha" = "$EXPECTED_SHA256" ] || fail "image sha256 mismatch: got ${actual_sha}, expected ${EXPECTED_SHA256}"
pass "image sha256 matches frozen D2H manifest"

python3 "$AVBTOOL" info_image --image "$IMAGE" >"$tmp_avb"
grep -Fq "$EXPECTED_FINGERPRINT_PART" "$tmp_avb" || fail "AVB fingerprint does not contain ${EXPECTED_FINGERPRINT_PART}"
pass "AVB fingerprint contains ${EXPECTED_FINGERPRINT_PART}"

contains_literal "${DEVICE_DIR}/AndroidProducts.mk" '$(LOCAL_DIR)/orangefox_NX809J_codingbr_d2h.mk' "PRODUCT_MAKEFILES D2H entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2h-ap2a-eng' "COMMON_LUNCH_CHOICES D2H eng entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2h-ap2a-userdebug' "COMMON_LUNCH_CHOICES D2H userdebug entry"

if grep -E '^RM11_NO_DECRYPT_PRODUCTS.*orangefox_NX809J_codingbr_d2h' "${DEVICE_DIR}/BoardConfig.mk" >/dev/null; then
  fail "${PRODUCT} is listed in RM11_NO_DECRYPT_PRODUCTS"
fi
pass "${PRODUCT} is not in RM11_NO_DECRYPT_PRODUCTS"

d2h_block="$(sed -n '/ifeq ($(TARGET_PRODUCT),orangefox_NX809J_codingbr_d2h)/,/endif/p' "${DEVICE_DIR}/BoardConfig.mk")"
printf '%s\n' "$d2h_block" | grep -Fq '$(DEVICE_PATH)/d2h' || fail "D2H TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2h"
pass "D2H TARGET_RECOVERY_DEVICE_DIRS includes \$(DEVICE_PATH)/d2h"

contains_literal "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2h.mk" "$EXPECTED_MARKER" "D2H source property marker"
contains_literal "${DEVICE_DIR}/d2h/recovery/root/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "D2H prepdecrypt.setpatch restore"
contains_literal "${DEVICE_DIR}/d2h/recovery/root/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "D2H prepdecrypt.vendor trigger restore"

binder_sha="$(sha256sum "${DEVICE_DIR}/d2h/recovery/root/system/lib64/libbinder_ndk.so" | awk '{print $1}')"
[ "$binder_sha" = "$EXPECTED_BINDER_NDK_SHA256" ] || fail "D2H source libbinder_ndk.so sha256 mismatch"
pass "D2H source libbinder_ndk.so matches TWRP-proven NDK36 build"

vintf_sha="$(sha256sum "${DEVICE_DIR}/d2h/recovery/root/system/lib64/libvintf.so" | awk '{print $1}')"
[ "$vintf_sha" = "$EXPECTED_LIBVINTF_SHA256" ] || fail "D2H source libvintf.so sha256 mismatch"
pass "D2H source libvintf.so matches TWRP-proven manifest parser build"

readelf_contains -Ws "${DEVICE_DIR}/d2h/recovery/root/system/lib64/libbinder_ndk.so" 'AIBinder_Class_setTransactionCodeToFunctionNameMap' "D2H source libbinder_ndk.so lacks transaction-name symbol"
readelf_contains -V "${DEVICE_DIR}/d2h/recovery/root/system/lib64/libbinder_ndk.so" 'LIBBINDER_NDK36' "D2H source libbinder_ndk.so lacks LIBBINDER_NDK36 version info"
pass "D2H source libbinder_ndk.so exports the transaction-name symbol with LIBBINDER_NDK36 support"

"$UNPACK_SCRIPT" "$IMAGE" "$UNPACK_DIR" >/dev/null
ROOT_DIR="${UNPACK_DIR}/ramdisk-root"
need_dir "$ROOT_DIR"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_MARKER}"
pass "unpacked ramdisk contains ${EXPECTED_MARKER}"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_TOUCH_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_TOUCH_MARKER}"
pass "unpacked ramdisk preserves ${EXPECTED_TOUCH_MARKER}"

need_file "${ROOT_DIR}/init.recovery.qcom.rc"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "unpacked D2H prepdecrypt.setpatch restore"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "unpacked D2H prepdecrypt.vendor trigger restore"

for trigger in \
  'sys.rm11.d2h.start_qseecomd' \
  'sys.rm11.d2h.start_keymint_qti' \
  'sys.rm11.d2h.start_gatekeeper' \
  'sys.rm11.d2h.start_weaver' \
  'sys.rm11.d2h.start_secure_element'
do
  grep -R -Fq "$trigger" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing trigger ${trigger}"
  pass "unpacked ramdisk contains ${trigger}"
done

if grep -R -Fq 'sys.rm11.d2g.start_' "$ROOT_DIR" 2>/dev/null; then
  fail "unpacked D2H ramdisk still contains D2G manual trigger names"
fi
pass "unpacked D2H ramdisk does not contain D2G trigger names"

if [ -e "${ROOT_DIR}/init.recovery.wlan.rc" ]; then
  fail "D2H ramdisk unexpectedly contains init.recovery.wlan.rc"
fi
pass "D2H ramdisk does not contain init.recovery.wlan.rc"

if grep -R -Fq 'import /init.recovery.wlan.rc' "${ROOT_DIR}/init.recovery.qcom.rc" 2>/dev/null; then
  fail "D2H init.recovery.qcom.rc imports Wi-Fi lane"
fi
pass "D2H init.recovery.qcom.rc does not import Wi-Fi lane"

need_file "${ROOT_DIR}/system/lib64/libbinder_ndk.so"
need_file "${ROOT_DIR}/system/lib64/libvintf.so"

ramdisk_binder_sha="$(sha256sum "${ROOT_DIR}/system/lib64/libbinder_ndk.so" | awk '{print $1}')"
[ "$ramdisk_binder_sha" = "$EXPECTED_BINDER_NDK_SHA256" ] || fail "unpacked libbinder_ndk.so sha256 mismatch"
pass "unpacked libbinder_ndk.so matches TWRP-proven NDK36 build"

ramdisk_vintf_sha="$(sha256sum "${ROOT_DIR}/system/lib64/libvintf.so" | awk '{print $1}')"
[ "$ramdisk_vintf_sha" = "$EXPECTED_LIBVINTF_SHA256" ] || fail "unpacked libvintf.so sha256 mismatch"
pass "unpacked libvintf.so matches TWRP-proven manifest parser build"

readelf_contains -Ws "${ROOT_DIR}/system/lib64/libbinder_ndk.so" 'AIBinder_Class_setTransactionCodeToFunctionNameMap' "unpacked libbinder_ndk.so lacks transaction-name symbol"
readelf_contains -V "${ROOT_DIR}/system/lib64/libbinder_ndk.so" 'LIBBINDER_NDK36' "unpacked libbinder_ndk.so lacks LIBBINDER_NDK36 version info"
pass "unpacked libbinder_ndk.so exports the transaction-name symbol with LIBBINDER_NDK36 support"

contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "1");' "OrangeFox crypto-enabled runtime property path"
contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "0");' "OrangeFox crypto-disabled runtime property path"
pass "crypto expectation is provable: D2H is outside RM11_NO_DECRYPT_PRODUCTS, so BoardConfig selects the TW_INCLUDE_CRYPTO lane that sets ro.orangefox.crypto_enabled=1 at runtime"

printf '\n===== AVB FINGERPRINT =====\n'
grep -F 'com.android.build.recovery.fingerprint' "$tmp_avb" || true

printf '\nRESULT: PASS. D2H preflash gate passed. This script does not flash anything.\n'
