#!/usr/bin/env bash
set -euo pipefail

# Collect read-only live recovery evidence over ADB. Does not flash.

ADB="${ADB:-/mnt/c/platform-tools/adb.exe}"
OUT_DIR="${OUT_DIR:-${HOME}/.android/repositories/MainAssets/recovery-forensics/recovery-live-$(date +%Y%m%d-%H%M%S)}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[ -x "$ADB" ] || fail "ADB not executable: $ADB"
mkdir -p "$OUT_DIR"

"$ADB" wait-for-device
"$ADB" get-state >"${OUT_DIR}/adb-state.txt" 2>&1 || true
"$ADB" shell getprop >"${OUT_DIR}/getprop.txt" 2>&1 || true
"$ADB" shell mount >"${OUT_DIR}/mount.txt" 2>&1 || true
"$ADB" shell cat /proc/mounts >"${OUT_DIR}/proc-mounts.txt" 2>&1 || true
"$ADB" shell cat /proc/cmdline >"${OUT_DIR}/proc-cmdline.txt" 2>&1 || true
"$ADB" shell ps -A >"${OUT_DIR}/ps-A.txt" 2>&1 || true
"$ADB" shell ls -l /dev/block/bootdevice/by-name >"${OUT_DIR}/by-name-ls.txt" 2>&1 || true
"$ADB" shell logcat -d >"${OUT_DIR}/logcat-d.txt" 2>&1 || true
"$ADB" shell dmesg >"${OUT_DIR}/dmesg.txt" 2>&1 || true
"$ADB" shell cat /tmp/recovery.log >"${OUT_DIR}/recovery.log" 2>&1 || true

grep -RInE 'rm11|orangefox|crypto|decrypt|qsee|keymint|gatekeeper|weaver|keystore|vold|wlan|wpa|dhcp|firmware|fatal|fail|denied' "$OUT_DIR" \
  >"${OUT_DIR}/focused-filter.txt" 2>/dev/null || true

printf 'Collected recovery logs: %s\n' "$OUT_DIR"
