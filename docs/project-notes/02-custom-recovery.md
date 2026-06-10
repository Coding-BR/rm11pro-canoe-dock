# Custom Recovery And OrangeFox

## Status

Current OrangeFox classification for RM11 Pro / NX809J:

```text
build-pass / flash-pass / boot-fail / rollback-pass
```

This is WIP only. Do not publish as usable recovery.

## Known Facts

From `rm11pro-canoe-dock` and local forensics:

- `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img` failed with `Bad Buffer Size`.
- `fastboot flash recovery_a OrangeFox-R12.0-Unofficial-NX809J.img` passed.
- Device routed to fastboot instead of recovery.
- Stock `recovery_a` rollback passed.
- Android boot was restored.

Image format finding:

- Stock and OrangeFox are Android boot image header v4 ramdisk-only recovery images.
- The hard mismatch is AVB metadata.
- Stock recovery has signed `SHA256_RSA4096` recovery footer with rollback index `1`.
- Failed OrangeFox had `Algorithm: NONE`, rollback index `0`, and no auth block.
- AVBTEST1 uses a generated validation key, not the OEM key.

Interpretation:

- If unlocked RM11 accepts non-stock recovery AVB keys, AVBTEST1 is the cautious next test.
- If RM11 requires OEM recovery key, AVBTEST1 may still route to fastboot.

## Required Before Calling Recovery Usable

Recovery needs all of this before release:

- Boot to recovery UI.
- Touch.
- ADB shell.
- Basic mount behavior.
- `/data` decryption or clear explanation that decryption is not supported.
- Reboot to system.
- Stock recovery rollback verified.
- Exact image hash.
- Exact slot tested.
- Rollback images available.

## What Helps Canoe Dock

Promote concise evidence and warnings:

- Current WIP classification.
- Image format/AVB comparison.
- Failure and rollback result.
- Recovery test checklist.

Do not promote:

- Raw 100 MB image blobs unless intentionally releasing them.
- Broad recovery claims from RM10/RM10S/Astra.
- Old failed image as a recommended flash.

## Current Assets

Local recovery assets found:

- `/mnt/e/Android/RM-11-Pro/RECOVERY/BACKUP-BEFORE-ORANGEFOX-2026-06-07/recovery_a_stock_before_orangefox.img`
- `/mnt/e/Android/RM-11-Pro/RECOVERY/BACKUP-BEFORE-ORANGEFOX-2026-06-07/recovery_b_stock_before_orangefox.img`
- `/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-2026-06-07/`
- `/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-avbtest1-2026-06-07/`

Repo note:

- Raw recovery images, logs, and headers now live under `/home/richtofen/android/repositories/MainAssets/recovery-forensics`.
- `rm11pro-canoe-dock/recovery-forensics/` is only a tracked pointer folder.
- Tracked OrangeFox summaries now live in [../orangefox-port/README.md](../orangefox-port/README.md).

## Source References

- `/mnt/e/Android/RM-11-Pro/staging-notes/RECOVERY.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/X1_FUTURE_ROM_RECOVERY_RUNWAY.md`
- `/home/richtofen/android/repositories/rm11pro-canoe-dock/docs/13-custom-recovery-wip.md`
- `/home/richtofen/android/repositories/rm11pro-canoe-dock/docs/14-orangefox-wip.md`
- `/home/richtofen/android/repositories/rm11pro-canoe-dock/ports/orangefox-recovery/device_nubia_NX809J/docs/`
