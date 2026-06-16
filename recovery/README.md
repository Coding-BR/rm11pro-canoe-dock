# OrangeFox Recovery Port Snapshot

This folder carries the dock-owned snapshot of the RM11 Pro OrangeFox device-tree port.

Source fork:

- GitHub: `https://github.com/Fractal-Echo/rm11pro-orangefox-recovery`
- Branch: `codex/nx809j-rm11pro-port`
- Remote branch head seen during import: `023c9d6a5a2504bd3bf4eb7b656244d78ce68d0c`
- Upstream ancestry: `plompomg/rm10pro-orangefox-recovery`

Imported snapshot:

- `device/zte/sm88XX/`

This is a source/config/docs import, not a full proprietary blob mirror. The active local fork had uncommitted RM11 port changes and untracked RM11 docs/prebuilt manifests, so the dock import used the local working tree instead of only the remote GitHub commit.

Included:

- Android product, board, device, and OrangeFox makefiles.
- Recovery fstab and init/service XML/RC configuration.
- WiFi, touch, VINTF, ueventd, task profile, and TWRP flag text configs.
- GitHub workflow files as inert source references under this subfolder. Only root
  `.github/workflows/` files are active Actions.
- RM11 OrangeFox build/flash/forensics docs.
- Android 16 prebuilt README and SHA256 manifest, now indexed under
  `prebuilts/` and `manifests/`.

Excluded:

- AVB private test keys and release key material.
- `prebuilt/kernel`, `dtbo.img`, raw images, zips, and generated build payloads.
- Vendor/system binaries, shared libraries, firmware blobs, and no-extension executable payloads.
- Local full OrangeFox source tree at `<orangefox-tree>`.

For the forensic narrative and current validation status, start at:

- `../docs/orangefox-port/README.md`
- `../docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md`
- `../docs/orangefox-port/17-local-orangefox-build-lane.md`
