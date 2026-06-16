# Rooting

## Status

Initial RM11 Pro root path uses Magisk on matching `init_boot`. Current validated public dock state later moves to KernelSU-only shell root after the AnyKernel3/KSU path.

Android 16 split boot rule:

- Root target is `init_boot`, not `boot`.
- Patch your own matching stock image.
- Do not patch random uploads.
- Do not patch another firmware version.

## Known Local Assets

Found on E: drive:

- `/mnt/e/Android/RM-11-Pro/BOOT/init_boot_a.img`
- `/mnt/e/Android/RM-11-Pro/BOOT/magisk_patched_rm11_init_boot_a.img`
- `/mnt/e/Android/RM-11-Pro/BOOT/BACKUP-ROOTED-2026-06-07/init_boot_a_magisk.img`
- `/mnt/e/Android/RM-11-Pro/BOOT/BACKUP-ROOTED-2026-06-07/boot_a_stock.img`
- `/mnt/e/Android/RM-11-Pro/BOOT/BACKUP-ROOTED-2026-06-07/vendor_boot_a_stock.img`
- `/mnt/e/Android/RM-11-Pro/BOOT/BACKUP-ROOTED-2026-06-07/vbmeta_a_stock.img`
- `/mnt/e/Android/RM-11-Pro/BOOT/BACKUP-ROOTED-2026-06-07/vbmeta_system_a_stock.img`

Do not publish these raw images unless intentionally releasing and scrubbed for safety.

## Root Validation

Magisk proof used in dock:

```powershell
adb shell su -c id
```

Earlier validation:

```text
uid=0(root) gid=0(root) groups=0(root) context=u:r:magisk:s0
```

KSU-only proof is tracked separately in [06-kernelsu-susfs.md](06-kernelsu-susfs.md).

## Safety Rules

- Keep stock `init_boot_a.img`.
- Keep exact firmware baseline.
- Record hash of stock and patched image.
- Do not mix root install with kernel RAM-boot validation.
- Do not use EDL as a routine root path.
- Do not flash `boot`, `vendor_boot`, `vbmeta`, or recovery while doing an init_boot-only root procedure unless that is the explicit test.

## What Helps Canoe Dock

Promote:

- high-level Magisk init_boot root guide.
- root proof command.
- migration note to KernelSU-only.
- rollback requirement.

Do not promote:

- local personal patched images.
- no-BL root experiments mixed with full unlock/fastboot restoration guide.
- root-bypass / app-evasion guidance.

## Source References

- `<repo-root>/docs/08-root-magisk-init-boot.md`
- `<repo-root>/docs/11-magisk-to-kernelsu.md`
- `<local-build-root>/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.tar.gz`
- `/mnt/e/Android/RM-11-Pro/staging-notes/KSU_PATCHING.md`
