#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/env-orangefox-nx809j.local}"
FORCE_DEVICE_TREE=0
SKIP_BUILD=0

usage() {
  cat <<'USAGE'
Usage: build-orangefox-nx809j-local.sh [--env FILE] [--force-device-tree] [--skip-build]

Builds RM11 Pro / NX809J OrangeFox recovery in a local, user-owned OrangeFox
tree. This script does not sync sources, flash a device, use GitHub Actions, or
read private maintainer paths.

Options:
  --env FILE             Source build variables from FILE.
  --force-device-tree    Allow updating a previously dock-managed copy.
  --skip-build           Install/link the device tree and stop before mka.
USAGE
}

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing command: $1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --env)
      shift
      [ "$#" -gt 0 ] || fail "--env needs a file"
      ENV_FILE="$1"
      ;;
    --force-device-tree)
      FORCE_DEVICE_TREE=1
      ;;
    --skip-build)
      SKIP_BUILD=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown argument: $1"
      ;;
  esac
  shift
done

[ -f "$ENV_FILE" ] || fail "missing env file: $ENV_FILE. Start from scripts/local-build/env-orangefox-nx809j.example"

# shellcheck source=/dev/null
source "$ENV_FILE"

: "${ORANGEFOX_TREE:?set ORANGEFOX_TREE in the env file}"
: "${DEVICE_TREE_SOURCE:=$REPO_ROOT/recovery/device/zte/sm88XX}"
: "${DEVICE_TREE_DEST_REL:=device/zte/sm88XX}"
: "${DEVICE_TREE_MODE:=copy}"
: "${PRODUCT_CODENAME:=NX809J}"
: "${LUNCH_TARGET:=orangefox_NX809J-ap2a-eng}"
: "${BUILD_GOALS:=adbd recoveryimage}"
: "${JOBS:=8}"
: "${ARTIFACTS_DIR:=$REPO_ROOT/out/local-orangefox-nx809j}"

DEVICE_TREE_DEST="$ORANGEFOX_TREE/$DEVICE_TREE_DEST_REL"
PRODUCT_OUT="${PRODUCT_OUT:-$ORANGEFOX_TREE/out/target/product/$PRODUCT_CODENAME}"

need_cmd sha256sum
[ -d "$REPO_ROOT/.git" ] || fail "not inside the dock repo: $REPO_ROOT"
[ -d "$ORANGEFOX_TREE/build" ] || fail "missing OrangeFox build tree: $ORANGEFOX_TREE"
[ -f "$ORANGEFOX_TREE/build/envsetup.sh" ] || fail "missing build/envsetup.sh under $ORANGEFOX_TREE"
[ -f "$DEVICE_TREE_SOURCE/BoardConfig.mk" ] || fail "missing RM11 device tree: $DEVICE_TREE_SOURCE"

install_device_tree() {
  mkdir -p "$(dirname "$DEVICE_TREE_DEST")"

  case "$DEVICE_TREE_MODE" in
    copy)
      need_cmd rsync
      if [ -e "$DEVICE_TREE_DEST" ] && [ ! -f "$DEVICE_TREE_DEST/.rm11-canoe-dock-managed" ] && [ "$FORCE_DEVICE_TREE" -ne 1 ]; then
        fail "refusing to update unmanaged tree: $DEVICE_TREE_DEST"
      fi
      mkdir -p "$DEVICE_TREE_DEST"
      rsync -a --exclude '.git' "$DEVICE_TREE_SOURCE/" "$DEVICE_TREE_DEST/"
      printf 'managed by rm11pro-canoe-dock local build script\n' >"$DEVICE_TREE_DEST/.rm11-canoe-dock-managed"
      ;;
    symlink)
      if [ -e "$DEVICE_TREE_DEST" ] && [ ! -L "$DEVICE_TREE_DEST" ]; then
        fail "refusing to replace non-symlink tree: $DEVICE_TREE_DEST"
      fi
      ln -sfn "$DEVICE_TREE_SOURCE" "$DEVICE_TREE_DEST"
      ;;
    *)
      fail "DEVICE_TREE_MODE must be copy or symlink, got: $DEVICE_TREE_MODE"
      ;;
  esac
}

collect_artifacts() {
  [ -d "$PRODUCT_OUT" ] || fail "missing product output directory: $PRODUCT_OUT"
  mkdir -p "$ARTIFACTS_DIR"

  mapfile -t artifacts < <(
    find "$PRODUCT_OUT" -maxdepth 1 -type f \
      \( -name 'OrangeFox*.img' -o -name 'OrangeFox*.zip' -o -name 'recovery.img' \) \
      | sort
  )

  [ "${#artifacts[@]}" -gt 0 ] || fail "no recovery artifacts found in $PRODUCT_OUT"

  for artifact in "${artifacts[@]}"; do
    cp -p "$artifact" "$ARTIFACTS_DIR/"
  done

  (
    cd "$ARTIFACTS_DIR"
    find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum >SHA256SUMS
  )

  printf 'Artifacts written to %s\n' "$ARTIFACTS_DIR"
  sed -n '1,120p' "$ARTIFACTS_DIR/SHA256SUMS"
}

printf 'Repo root: %s\n' "$REPO_ROOT"
printf 'OrangeFox tree: %s\n' "$ORANGEFOX_TREE"
printf 'Device tree source: %s\n' "$DEVICE_TREE_SOURCE"
printf 'Device tree target: %s\n' "$DEVICE_TREE_DEST"

install_device_tree

if [ "$SKIP_BUILD" -eq 1 ]; then
  printf 'Device tree prepared. Skipping build by request.\n'
  exit 0
fi

cd "$ORANGEFOX_TREE"
# shellcheck source=/dev/null
source build/envsetup.sh
lunch "$LUNCH_TARGET"

read -r -a goals <<<"$BUILD_GOALS"
mka "-j${JOBS}" "${goals[@]}"

collect_artifacts
