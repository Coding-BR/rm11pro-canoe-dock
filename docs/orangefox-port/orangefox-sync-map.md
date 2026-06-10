# OrangeFox Sync Map

This records how the local OrangeFox source tree was created and which parts were merged into Canoe Dock.

Local paths:

- `/home/richtofen/android/repositories/MainAssets/OrangeFox_sync`: helper checkout used to sync and patch OrangeFox sources.
- `/home/richtofen/android/repositories/MainAssets/fox_14.1`: full OrangeFox/TWRP source tree and build workspace; generated `out/` artifacts were deleted during cleanup.
- `/home/richtofen/android/repositories/MainAssets/fox_14.1/device/nubia/NX809J`: copied OrangeFox device tree used for the RM11 build.
- `/home/richtofen/android/repositories/rm11pro-canoe-dock/ports/orangefox-recovery/device_nubia_NX809J`: current local fork path for the RM10 Pro to RM11 Pro OrangeFox device-tree port.

Imported into this dock repo:

- `scripts/orangefox-sync/README.md`
- `scripts/orangefox-sync/orangefox_sync.sh`
- `scripts/orangefox-sync/update_fox.sh`
- `scripts/orangefox-sync/patches/patch-manifest-fox_14.1.diff`
- `scripts/orangefox-sync/patches/patch-remove-minimal-fox_14.1.diff`
- `scripts/orangefox-sync/patches/patch-vendor-twrp-fox_14.1.diff`
- `scripts/orangefox-sync/patches/patch-vold-fox_14.1.diff`
- `scripts/orangefox-sync/patches/usage.txt`
- `ports/orangefox-recovery/device_nubia_NX809J`: curated source/config/docs snapshot of the RM11 OrangeFox port.

Not imported:

- `/home/richtofen/android/repositories/MainAssets/fox_14.1`: full source tree; generated build output is intentionally absent after cleanup.
- Deleted OrangeFox sync build logs, pid files, and status files.
- Legacy fox_12.1 patches: retained locally but not needed for the RM11 fox_14.1 recovery line.

Known build command:

```bash
cd "/home/richtofen/android/repositories/MainAssets/fox_14.1"
source build/envsetup.sh
lunch orangefox_NX809J-ap2a-eng
mka -j8 adbd recoveryimage
```

Result recorded in `rm11-orangefox-build-pass-2026-06-07.md`:

- `OrangeFox-R12.0-Unofficial-NX809J.img`
- `OrangeFox-R12.0-Unofficial-NX809J.zip`
- Image size: `104857600` bytes, matching the recovery partition size.

The copied sync scripts are provenance and rebuild helpers. The active recovery device tree remains the source repo named above unless or until it is merged directly into the dock.
