#!/usr/bin/env bash
set -euo pipefail

# Read-only D2G preflash gate for RM11 Pro / NX809J.
# It verifies the frozen image identity plus the built recovery-root markers
# that prove the D2G overlay/property lane landed before any flash.

FOX_DIR="${FOX_DIR:-/home/richtofen/.android/repositories/MainAssets/fox_14.1}"
ARTIFACT_DIR="${ARTIFACT_DIR:-/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2g-crypto-enabled-manual-service-overlay}"
IMAGE="${IMAGE:-${ARTIFACT_DIR}/OrangeFox-R12.0-Unofficial-NX809J-d2g-crypto-enabled-manual-service-overlay.img}"
EXPECTED_BYTES="${EXPECTED_BYTES:-104857600}"
EXPECTED_SHA256="${EXPECTED_SHA256:-a806ffcc82eeec0ffd29d2c07f5f8e6c9a8669fce783ce3901e4f6711baa9664}"
EXPECTED_FINGERPRINT_PART="${EXPECTED_FINGERPRINT_PART:-orangefox_NX809J_codingbr_d2g}"
EXPECTED_MARKER="${EXPECTED_MARKER:-ro.rm11.decrypt_candidate_d2g=d2g-crypto-enabled-manual-service-overlay}"

PRODUCT="orangefox_NX809J_codingbr_d2g"
DEVICE_DIR="${FOX_DIR}/device/zte/sm88XX"
ROOT_DIR="${FOX_DIR}/out/target/product/sm88XX/recovery/root"
AVBTOOL="${FOX_DIR}/external/avb/avbtool.py"
TWRP_CPP="${FOX_DIR}/bootable/recovery/twrp.cpp"

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
need_file "${DEVICE_DIR}/AndroidProducts.mk"
need_file "${DEVICE_DIR}/BoardConfig.mk"
need_file "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2g.mk"
need_file "${DEVICE_DIR}/d2g/recovery/root/init.recovery.qcom.rc"
need_file "$TWRP_CPP"
need_dir "$ROOT_DIR"

printf '===== D2G PREFLASH VERIFY =====\n'
printf 'image: %s\n' "$IMAGE"
printf 'fox_dir: %s\n' "$FOX_DIR"
printf 'built_root: %s\n\n' "$ROOT_DIR"

actual_bytes="$(stat -c '%s' "$IMAGE")"
[ "$actual_bytes" = "$EXPECTED_BYTES" ] || fail "image size mismatch: got ${actual_bytes}, expected ${EXPECTED_BYTES}"
pass "image size is ${EXPECTED_BYTES} bytes"

actual_sha="$(sha256sum "$IMAGE" | awk '{print $1}')"
[ "$actual_sha" = "$EXPECTED_SHA256" ] || fail "image sha256 mismatch: got ${actual_sha}, expected ${EXPECTED_SHA256}"
pass "image sha256 matches frozen D2G manifest"

python3 "$AVBTOOL" info_image --image "$IMAGE" >"$tmp_avb"
grep -Fq "$EXPECTED_FINGERPRINT_PART" "$tmp_avb" || fail "AVB fingerprint does not contain ${EXPECTED_FINGERPRINT_PART}"
pass "AVB fingerprint contains ${EXPECTED_FINGERPRINT_PART}"

contains_literal "${DEVICE_DIR}/AndroidProducts.mk" '$(LOCAL_DIR)/orangefox_NX809J_codingbr_d2g.mk' "PRODUCT_MAKEFILES D2G entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2g-ap2a-eng' "COMMON_LUNCH_CHOICES D2G eng entry"
contains_literal "${DEVICE_DIR}/AndroidProducts.mk" 'orangefox_NX809J_codingbr_d2g-ap2a-userdebug' "COMMON_LUNCH_CHOICES D2G userdebug entry"

if grep -E '^RM11_NO_DECRYPT_PRODUCTS.*orangefox_NX809J_codingbr_d2g' "${DEVICE_DIR}/BoardConfig.mk" >/dev/null; then
  fail "${PRODUCT} is listed in RM11_NO_DECRYPT_PRODUCTS"
fi
pass "${PRODUCT} is not in RM11_NO_DECRYPT_PRODUCTS"

d2g_block="$(sed -n '/ifeq ($(TARGET_PRODUCT),orangefox_NX809J_codingbr_d2g)/,/endif/p' "${DEVICE_DIR}/BoardConfig.mk")"
printf '%s\n' "$d2g_block" | grep -Fq '$(DEVICE_PATH)/d2g' || fail "D2G TARGET_RECOVERY_DEVICE_DIRS block does not include \$(DEVICE_PATH)/d2g"
pass "D2G TARGET_RECOVERY_DEVICE_DIRS includes \$(DEVICE_PATH)/d2g"

contains_literal "${DEVICE_DIR}/orangefox_NX809J_codingbr_d2g.mk" "$EXPECTED_MARKER" "D2G source property marker"

grep -R --include='default.prop' --include='prop.default' -Fq "$EXPECTED_MARKER" "$ROOT_DIR" 2>/dev/null || fail "built recovery root is missing ${EXPECTED_MARKER}"
pass "built recovery root contains ${EXPECTED_MARKER}"

for trigger in \
  'sys.rm11.d2g.start_qseecomd' \
  'sys.rm11.d2g.start_keymint_qti' \
  'sys.rm11.d2g.start_gatekeeper' \
  'sys.rm11.d2g.start_weaver' \
  'sys.rm11.d2g.start_secure_element'
do
  grep -R -Fq "$trigger" "$ROOT_DIR" 2>/dev/null || fail "built recovery root is missing trigger ${trigger}"
  pass "built recovery root contains ${trigger}"
done

contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "1");' "OrangeFox crypto-enabled runtime property path"
contains_literal "$TWRP_CPP" 'property_set("ro.orangefox.crypto_enabled", "0");' "OrangeFox crypto-disabled runtime property path"
pass "crypto expectation is provable: D2G is outside RM11_NO_DECRYPT_PRODUCTS, so BoardConfig selects the TW_INCLUDE_CRYPTO lane that sets ro.orangefox.crypto_enabled=1 at runtime"

printf '\n===== AVB FINGERPRINT =====\n'
grep -F 'com.android.build.recovery.fingerprint' "$tmp_avb" || true

printf '\nRESULT: PASS. D2G preflash gate passed. This script does not flash anything.\n'
