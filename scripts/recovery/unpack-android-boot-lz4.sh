#!/usr/bin/env bash
set -euo pipefail

# Unpack an Android boot/recovery image and extract an lz4/gzip/xz/zstd/bzip2
# cpio ramdisk when possible. Read-only with respect to the input image.

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <boot-or-recovery.img> <out-dir> [unpack_bootimg.py]" >&2
  exit 2
fi

IMAGE="$(realpath "$1")"
OUT_DIR="$(realpath -m "$2")"
UNPACK_BOOTIMG="${3:-${UNPACK_BOOTIMG:-/home/richtofen/.android/repositories/MainAssets/fox_14.1/system/tools/mkbootimg/unpack_bootimg.py}}"
UNPACK_BOOTIMG="$(realpath "$UNPACK_BOOTIMG")"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing command: $1"
}

[ -f "$IMAGE" ] || fail "image not found: $IMAGE"
[ -f "$UNPACK_BOOTIMG" ] || fail "unpack_bootimg.py not found: $UNPACK_BOOTIMG"
need_cmd python3
need_cmd file
need_cmd cpio

mkdir -p "$OUT_DIR"
python3 "$UNPACK_BOOTIMG" --boot_img "$IMAGE" --out "$OUT_DIR" >"${OUT_DIR}/unpack_bootimg.txt"

RAMDISK="${OUT_DIR}/ramdisk"
[ -f "$RAMDISK" ] || fail "unpack did not produce ramdisk: $RAMDISK"

rm -rf "${OUT_DIR}/ramdisk-root"
mkdir -p "${OUT_DIR}/ramdisk-root"

kind="$(file -b "$RAMDISK")"
case "$kind" in
  *LZ4*)
    need_cmd lz4
    lz4 -dc "$RAMDISK" | (cd "${OUT_DIR}/ramdisk-root" && cpio -idm --quiet)
    ;;
  *gzip*|*Gzip*)
    gzip -dc "$RAMDISK" | (cd "${OUT_DIR}/ramdisk-root" && cpio -idm --quiet)
    ;;
  *Zstandard*|*zstd*)
    need_cmd zstd
    zstd -dc "$RAMDISK" | (cd "${OUT_DIR}/ramdisk-root" && cpio -idm --quiet)
    ;;
  *XZ*)
    xz -dc "$RAMDISK" | (cd "${OUT_DIR}/ramdisk-root" && cpio -idm --quiet)
    ;;
  *bzip2*)
    bzip2 -dc "$RAMDISK" | (cd "${OUT_DIR}/ramdisk-root" && cpio -idm --quiet)
    ;;
  *cpio*)
    (cd "${OUT_DIR}/ramdisk-root" && cpio -idm --quiet <"$RAMDISK")
    ;;
  *)
    fail "unsupported ramdisk format: $kind"
    ;;
esac

find "${OUT_DIR}/ramdisk-root" -type f | sed "s#^${OUT_DIR}/ramdisk-root/##" | sort >"${OUT_DIR}/ramdisk-filelist.txt"
printf 'image=%s\nout=%s\nramdisk_format=%s\n' "$IMAGE" "$OUT_DIR" "$kind"
