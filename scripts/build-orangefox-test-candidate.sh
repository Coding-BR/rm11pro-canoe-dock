#!/usr/bin/env bash
set -euo pipefail

# Build-only helper for the RM11 Pro / NX809J OrangeFox test candidate.
# It syncs the dock device tree into the local OrangeFox workspace and builds
# recoveryimage. It does not flash anything.

DOCK_DIR="${DOCK_DIR:-/home/richtofen/android/repositories/rm11pro-canoe-dock}"
FOX_DIR="${FOX_DIR:-/home/richtofen/android/repositories/MainAssets/fox_14.1}"
DEVICE_TREE="${DOCK_DIR}/ports/orangefox-recovery/device_nubia_NX809J"
FOX_DEVICE_TREE="${FOX_DIR}/device/nubia/NX809J"
JOBS="${JOBS:-8}"
CLEAN_OUT=0
COPY_WINDOWS_TEMP=0

for arg in "$@"; do
  case "$arg" in
    --clean)
      CLEAN_OUT=1
      ;;
    --copy-windows-temp)
      COPY_WINDOWS_TEMP=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--clean] [--copy-windows-temp]" >&2
      exit 2
      ;;
  esac
done

test -d "$DOCK_DIR/.git" || { echo "Missing dock repo: $DOCK_DIR" >&2; exit 1; }
test -d "$FOX_DIR/build" || { echo "Missing OrangeFox workspace: $FOX_DIR" >&2; exit 1; }
test -f "$DEVICE_TREE/BoardConfig.mk" || { echo "Missing device tree: $DEVICE_TREE" >&2; exit 1; }

mkdir -p "$(dirname "$FOX_DEVICE_TREE")"
rsync -a "$DEVICE_TREE/" "$FOX_DEVICE_TREE/"

cd "$FOX_DIR"
export OUT_DIR="${FOX_DIR}/out"

if [ "$CLEAN_OUT" -eq 1 ]; then
  rm -rf "$OUT_DIR"
fi

# shellcheck source=/dev/null
source build/envsetup.sh
lunch orangefox_NX809J-ap2a-eng
mka "-j${JOBS}" adbd recoveryimage

IMAGE="${OUT_DIR}/target/product/NX809J/OrangeFox-R12.0-Unofficial-NX809J.img"
ZIP="${OUT_DIR}/target/product/NX809J/OrangeFox-R12.0-Unofficial-NX809J.zip"

sha256sum "$IMAGE" "$ZIP"
ls -lh "$IMAGE" "$ZIP"

if [ "$COPY_WINDOWS_TEMP" -eq 1 ]; then
  mkdir -p /mnt/c/temp
  stamp="$(date +%Y%m%d-%H%M%S)"
  cp -f "$IMAGE" "/mnt/c/temp/orangefox-nx809j-stockfstab-mininit-${stamp}.img"
  cp -f "$ZIP" "/mnt/c/temp/orangefox-nx809j-stockfstab-mininit-${stamp}.zip"
  echo "Copied test candidate to /mnt/c/temp with stamp ${stamp}."
fi
