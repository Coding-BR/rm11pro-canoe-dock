#!/usr/bin/env bash
set -euo pipefail

# Fetch-only/clone-only sync for the post-recovery Droidspace lane.
# Existing repositories are fetched, not pulled or reset.

REPO_ROOT="${REPO_ROOT:-${HOME}/.android/repositories}"
TARGET_DIR="${TARGET_DIR:-${REPO_ROOT}/droidspace-core}"

clone_or_fetch() {
  local repo="$1"
  local branch="$2"
  local url="https://github.com/Fractal-Echo/${repo}.git"
  local dir="${TARGET_DIR}/${repo}"

  printf '\n===== %s =====\n' "$repo"

  if [ -d "${dir}/.git" ]; then
    printf 'fetching existing repo: %s\n' "$dir"
    git -C "$dir" remote -v | sed -n '1,4p'
    git -C "$dir" fetch --all --prune
    git -C "$dir" status -sb
    git -C "$dir" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null || true
    return
  fi

  if [ -e "$dir" ]; then
    printf 'refusing to overwrite non-git path: %s\n' "$dir" >&2
    return 1
  fi

  printf 'cloning %s branch %s into %s\n' "$url" "$branch" "$dir"
  git clone --branch "$branch" "$url" "$dir"
  git -C "$dir" status -sb
}

mkdir -p "$TARGET_DIR"
printf 'target_dir: %s\n' "$TARGET_DIR"

clone_or_fetch "Droidspaces-OSS" "main"
clone_or_fetch "Droidspaces-rootfs-KDE-builder" "main"
clone_or_fetch "Droidspaces_Kernel_patch" "main"
clone_or_fetch "busybox-droidspaces" "main"
clone_or_fetch "toybox-droidspaces" "main-kernel"
clone_or_fetch "socketd" "main"
clone_or_fetch "webui" "main"
clone_or_fetch "linuxcontainers-mirror" "main"
clone_or_fetch "VirtualAP" "main"
clone_or_fetch "termux-app" "master"
clone_or_fetch "termux-x11" "master"

cat <<'EOF'

Deferred heavy repos:
  Fractal-Echo/Droidspaces-kernel
  Fractal-Echo/mesa-for-android-container-rm11pro
  Fractal-Echo/Winlator-Ludashi-emulador-windows-acompanhar
  Fractal-Echo/droidspaces-recovery-hack-example

This script intentionally does not pull, merge, reset, clean, or build.
EOF
