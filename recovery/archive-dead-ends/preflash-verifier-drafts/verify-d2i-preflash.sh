#!/usr/bin/env bash
set -euo pipefail

# Read-only D2I preflash gate for RM11 Pro / NX809J.
# D2I intentionally keeps D2G's stable global recovery userspace and restores
# only TWRP prepdecrypt semantics.

FOX_DIR="${FOX_DIR:-<orangefox-tree>}"
ARTIFACT_DIR="${ARTIFACT_DIR:-<local-build-root>/recovery-forensics/d2i-prepdecrypt-only-probe}"
IMAGE="${IMAGE:-${ARTIFACT_DIR}/OrangeFox-R12.0-Unofficial-NX809J-d2i-prepdecrypt-only-probe.img}"
EXPECTED_BYTES="${EXPECTED_BYTES:-104857600}"
EXPECTED_SHA256="${EXPECTED_SHA256:-2a95570f2fced2fa24aa7c474e91ddb78f65379bc77df0c1027ed614b9fa570d}"
EXPECTED_FINGERPRINT_PART="${EXPECTED_FINGERPRINT_PART:-orangefox_NX809J_codingbr_d2i}"
EXPECTED_MARKER="${EXPECTED_MARKER:-ro.rm11.decrypt_candidate_d2i=d2i-prepdecrypt-only-probe}"
EXPECTED_TOUCH_MARKER="${EXPECTED_TOUCH_MARKER:-ro.rm11.touch_candidate_d1t3=d1t3-minuitwrp-touch-normalization}"
TWRP_BINDER_NDK_SHA256="${TWRP_BINDER_NDK_SHA256:-d238c5bfb2ffb56af8631fb9e23dcc343e00e9b7179e18231929f2d4f67175a3}"
TWRP_LIBVINTF_SHA256="${TWRP_LIBVINTF_SHA256:-e3d35b5b781f85df704d48f8eb14c4e28a2ea9de4063041c0eb10832dea5c8b9}"

PRODUCT="orangefox_NX809J_codingbr_d2i"
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
  pass "$label found in $file"
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
need_file "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2i.mk"
need_file "${DEVICE_DIR}/d2i/recovery/root/init.recovery.qcom.rc"
need_file "$TWRP_CPP"

[ ! -e "$UNPACK_DIR" ] || fail "unpack directory already exists: $UNPACK_DIR"

printf '===== D2I PREFLASH VERIFY =====\n'
printf 'image: %s\n' "$IMAGE"
printf 'fox_dir: %s\n' "$FOX_DIR"
printf 'unpack_dir: %s\n\n' "$UNPACK_DIR"

actual_bytes="$(stat -c '%s' "$IMAGE")"
[ "$actual_bytes" = "$EXPECTED_BYTES" ] || fail "image size mismatch: got ${actual_bytes}, expected ${EXPECTED_BYTES}"
pass "image size is ${EXPECTED_BYTES} bytes"

actual_sha="$(sha256sum "$IMAGE" | awk '{print $1}')"
[ "$actual_sha" = "$EXPECTED_SHA256" ] || fail "image sha256 mismatch: got ${actual_sha}, expected ${EXPECTED_SHA256}"
pass "image sha256 matches frozen D2I manifest"

python3 "$AVBTOOL" info_image --image "$IMAGE" >"$tmp_avb"
grep -Fq "$EXPECTED_FINGERPRINT_PART" "$tmp_avb" || fail "AVB fingerprint does not contain ${EXPECTED_FINGERPRINT_PART}"
pass "AVB fingerprint contains ${EXPECTED_FINGERPRINT_PART}"

contains_literal "${DEVICE_DIR}/AndroidProducts.mk" '$(LOCAL_DIR)/orangefox_NX809J_codingbr_d2i.mk' "PRODUCT_MAKEFILES D2I entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2i-ap2a-eng' "COMMON_LUNCH_CHOICES D2I eng entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2i-ap2a-userdebug' "COMMON_LUNCH_CHOICES D2I userdebug entry"

if grep -E '^RM11_NO_DECRYPT_PRODUCTS.*orangefox_NX809J_codingbr_d2i' "${DEVICE_DIR}/BoardConfig.mk" >/dev/null; then
  fail "${PRODUCT} is listed in RM11_NO_DECRYPT_PRODUCTS"
fi
pass "${PRODUCT} is not in RM11_NO_DECRYPT_PRODUCTS"

d2i_block="$(sed -n '/ifeq ($(TARGET_PRODUCT),orangefox_NX809J_codingbr_d2i)/,/endif/p' "${DEVICE_DIR}/BoardConfig.mk")"
printf '%s\n' "$d2i_block" | grep -Fq '$(DEVICE_PATH)/d2i' || fail "D2I TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2i"
if printf '%s\n' "$d2i_block" | grep -Fq '$(DEVICE_PATH)/d2h'; then
  fail "D2I TARGET_RECOVERY_DEVICE_DIRS includes D2H"
fi
pass "D2I TARGET_RECOVERY_DEVICE_DIRS includes d2i and excludes d2h"

if [ -e "${DEVICE_DIR}/d2i/recovery/root/system/lib64/libbinder_ndk.so" ] || [ -e "${DEVICE_DIR}/d2i/recovery/root/system/lib64/libvintf.so" ]; then
  fail "D2I source overlay contains global binder/VINTF library replacement"
fi
pass "D2I source overlay has no global binder/VINTF library replacement"

contains_literal "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2i.mk" "$EXPECTED_MARKER" "D2I source property marker"
contains_literal "${DEVICE_DIR}/d2i/recovery/root/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "D2I prepdecrypt.setpatch restore"
contains_literal "${DEVICE_DIR}/d2i/recovery/root/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "D2I prepdecrypt.vendor trigger restore"

"$UNPACK_SCRIPT" "$IMAGE" "$UNPACK_DIR" >/dev/null
ROOT_DIR="${UNPACK_DIR}/ramdisk-root"
need_dir "$ROOT_DIR"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_MARKER}"
pass "unpacked ramdisk contains ${EXPECTED_MARKER}"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_TOUCH_MARKER" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing ${EXPECTED_TOUCH_MARKER}"
pass "unpacked ramdisk preserves ${EXPECTED_TOUCH_MARKER}"

need_file "${ROOT_DIR}/init.recovery.qcom.rc"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'setprop prepdecrypt.setpatch true' "unpacked D2I prepdecrypt.setpatch restore"
contains_literal "${ROOT_DIR}/init.recovery.qcom.rc" 'start prepdecrypt.vendor' "unpacked D2I prepdecrypt.vendor trigger restore"

for trigger in \
  'sys.rm11.d2i.start_qseecomd' \
  'sys.rm11.d2i.start_keymint_qti' \
  'sys.rm11.d2i.start_gatekeeper' \
  'sys.rm11.d2i.start_weaver' \
  'sys.rm11.d2i.start_secure_element'
do
  grep -R -Fq "$trigger" "$ROOT_DIR" 2>/dev/null || fail "unpacked ramdisk is missing trigger ${trigger}"
  pass "unpacked ramdisk contains ${trigger}"
done

if grep -R -Fq 'sys.rm11.d2h.start_' "$ROOT_DIR" 2>/dev/null; then
  fail "unpacked D2I ramdisk contains D2H trigger names"
fi
pass "unpacked D2I ramdisk does not contain D2H trigger names"

if [ -e "${ROOT_DIR}/init.recovery.wlan.rc" ]; then
  fail "D2I ramdisk unexpectedly contains init.recovery.wlan.rc"
fi
pass "D2I ramdisk does not contain init.recovery.wlan.rc"

if grep -R -Fq 'import /init.recovery.wlan.rc' "${ROOT_DIR}/init.recovery.qcom.rc" 2>/dev/null; then
  fail "D2I init.recovery.qcom.rc imports Wi-Fi lane"
fi
pass "D2I init.recovery.qcom.rc does not import Wi-Fi lane"

need_file "${ROOT_DIR}/system/lib64/libbinder_ndk.so"
need_file "${ROOT_DIR}/system/lib64/libvintf.so"

ramdisk_binder_sha="$(sha256sum "${ROOT_DIR}/system/lib64/libbinder_ndk.so" | awk '{print $1}')"
[ "$ramdisk_binder_sha" != "$TWRP_BINDER_NDK_SHA256" ] || fail "unpacked D2I libbinder_ndk.so matches D2H/TWRP global replacement"
pass "unpacked D2I libbinder_ndk.so is not the D2H/TWRP global replacement"

ramdisk_vintf_sha="$(sha256sum "${ROOT_DIR}/system/lib64/libvintf.so" | awk '{print $1}')"
[ "$ramdisk_vintf_sha" != "$TWRP_LIBVINTF_SHA256" ] || fail "unpacked D2I libvintf.so matches D2H/TWRP global replacement"
pass "unpacked D2I libvintf.so is not the D2H/TWRP global replacement"

contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "1");' "OrangeFox crypto-enabled runtime property path"
contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "0");' "OrangeFox crypto-disabled runtime property path"
pass "crypto expectation is provable: D2I is outside RM11_NO_DECRYPT_PRODUCTS, so BoardConfig selects the TW_INCLUDE_CRYPTO lane that sets ro.orangefox.crypto_enabled=1 at runtime"

printf '\n===== AVB FINGERPRINT =====\n'
grep -F 'com.android.build.recovery.fingerprint' "$tmp_avb" || true

printf '\nRESULT: PASS. D2I preflash gate passed. This script does not flash anything.\n'
