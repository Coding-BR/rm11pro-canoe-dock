#!/usr/bin/env bash
set -euo pipefail

# Guarded rollback helper for restoring stock recovery_a from booted Android.
# This writes recovery_a only when the explicit confirmation flag is present.

ADB="${ADB:-/mnt/c/platform-tools/adb.exe}"
STOCK_IMAGE="${1:-}"
CONFIRM="${2:-}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

if [ -z "$STOCK_IMAGE" ] || [ "$CONFIRM" != "--i-understand-this-writes-recovery-a" ]; then
  cat >&2 <<'EOF'
Usage:
  rollback-stock-recovery-a.sh <stock-recovery-a.img> --i-understand-this-writes-recovery-a

This uses adb + su from booted Android and writes:
  /dev/block/bootdevice/by-name/recovery_a

It does not touch recovery_b.
EOF
  exit 2
fi

[ -x "$ADB" ] || fail "ADB not executable: $ADB"
[ -f "$STOCK_IMAGE" ] || fail "stock image not found: $STOCK_IMAGE"

bytes="$(stat -c '%s' "$STOCK_IMAGE")"
[ "$bytes" = "104857600" ] || fail "unexpected recovery image size: $bytes"

base="$(basename "$STOCK_IMAGE")"
remote="/sdcard/${base}"

"$ADB" wait-for-device
"$ADB" push "$STOCK_IMAGE" "$remote"
"$ADB" shell su -c "dd if='${remote}' of=/dev/block/bootdevice/by-name/recovery_a bs=4M status=progress"
"$ADB" shell su -c sync

printf 'Restored recovery_a from %s. Reboot manually after confirming the output.\n' "$STOCK_IMAGE"
