# ROM Deodexing

## Status

ROM deodexing appears as a future ROM-building lane, not an active validated RM11 task.

Detected local folder:

- `/mnt/e/Android/RM-11-Pro/BOOT/04-ABL-Unlock-Debloat-Deodex-16`

The old notes had small `deodex`, `odex`, `vdex`, and `oat` keyword presence, but not enough artifact-level evidence for a working deodex pipeline.

## Required Before Active Work

Before deodexing becomes active:

- Identify exact stock firmware build.
- Hash `system`, `system_ext`, `product`, `vendor`, and `odm` images.
- Decide whether target is a GSI overlay, stock ROM mod, or full ROM rebuild.
- Extract APK/JAR pairs with matching `.vdex`/`.odex`.
- Verify bootclasspath and framework dependencies.
- Build a reversible flash or dynamic-partition test path.
- Confirm boot, core apps, telephony, camera, RedMagic features, and rollback.

## What Helps Canoe Dock

Promote:

- deodex report template.
- warnings that deodexed ROM images are firmware-specific.
- tested ROM/GSI result pages.

Do not promote:

- generic kitchen output.
- raw private app data.
- deodexed system images without rollback and hashes.

## Source References

- `/mnt/e/Android/RM-11-Pro/BOOT/04-ABL-Unlock-Debloat-Deodex-16`
- `/mnt/e/Android/RM-11-Pro/staging-notes/ROM_MAKING_USEFUL_KEEPERS.md`
- `<local-build-root>/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.tar.gz`
