#!/usr/bin/env bash
set -euo pipefail

# Compare a working TWRP recovery ramdisk against an OrangeFox ramdisk.
# Inputs may be extracted ramdisk roots or image files. This script produces
# reports only; it never copies files between trees.

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <twrp-img-or-root> <orangefox-img-or-root> <out-dir>" >&2
  exit 2
fi

TWRP_INPUT="$1"
FOX_INPUT="$2"
OUT_DIR="$3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNPACKER="${SCRIPT_DIR}/unpack-android-boot-lz4.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

resolve_root() {
  local input="$1"
  local name="$2"
  local out="$3"

  if [ -d "$input" ]; then
    printf '%s\n' "$input"
    return
  fi

  [ -f "$input" ] || fail "missing input: $input"
  "$UNPACKER" "$input" "${out}/${name}" >/dev/null
  printf '%s\n' "${out}/${name}/ramdisk-root"
}

mkdir -p "$OUT_DIR"
TWRP_ROOT="$(resolve_root "$TWRP_INPUT" twrp "$OUT_DIR")"
FOX_ROOT="$(resolve_root "$FOX_INPUT" orangefox "$OUT_DIR")"

[ -d "$TWRP_ROOT" ] || fail "missing TWRP root: $TWRP_ROOT"
[ -d "$FOX_ROOT" ] || fail "missing OrangeFox root: $FOX_ROOT"

find "$TWRP_ROOT" -type f | sed "s#^${TWRP_ROOT}/##" | sort >"${OUT_DIR}/twrp-filelist.txt"
find "$FOX_ROOT" -type f | sed "s#^${FOX_ROOT}/##" | sort >"${OUT_DIR}/orangefox-filelist.txt"
diff -u "${OUT_DIR}/twrp-filelist.txt" "${OUT_DIR}/orangefox-filelist.txt" >"${OUT_DIR}/filelist.diff" || true

{
  printf 'TWRP root: %s\n' "$TWRP_ROOT"
  printf 'OrangeFox root: %s\n\n' "$FOX_ROOT"
  printf '## Focused Path Diffs\n\n'
} >"${OUT_DIR}/report.txt"

for rel in \
  'vendor/etc/init' \
  'vendor/bin' \
  'vendor/bin/hw' \
  'system/bin' \
  'system/bin/init_wlan.sh' \
  'init.recovery.wlan.rc' \
  'prepdecrypt.sh'
do
  {
    printf '\n===== %s =====\n' "$rel"
    if [ -e "${TWRP_ROOT}/${rel}" ] || [ -e "${FOX_ROOT}/${rel}" ]; then
      diff -ruN "${TWRP_ROOT}/${rel}" "${FOX_ROOT}/${rel}" || true
    else
      printf 'missing in both roots\n'
    fi
  } >>"${OUT_DIR}/report.txt"
done

for pattern in \
  'init*.rc' \
  'fstab*' \
  '*wpa*' \
  '*dhcp*' \
  '*wlan*'
do
  {
    printf '\n===== find %s =====\n' "$pattern"
    printf -- '-- TWRP --\n'
    (cd "$TWRP_ROOT" && find . -name "$pattern" -print | sort)
    printf -- '-- OrangeFox --\n'
    (cd "$FOX_ROOT" && find . -name "$pattern" -print | sort)
  } >>"${OUT_DIR}/report.txt"
done

for root_name in twrp orangefox; do
  case "$root_name" in
    twrp) root="$TWRP_ROOT" ;;
    orangefox) root="$FOX_ROOT" ;;
  esac
  grep -RInE 'qsee|keymint|gatekeeper|weaver|secure_element|keystore|vold|crypto|decrypt|wpa|dhcp|wlan|firmware' "$root" \
    >"${OUT_DIR}/${root_name}-focused-grep.txt" 2>/dev/null || true
done

printf 'Wrote %s\n' "$OUT_DIR"
