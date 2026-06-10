# Dock Import Notes

This directory is a curated copy of the RM11 Pro / NX809J OrangeFox device-tree fork.

Source:

- Local repo: `/home/richtofen/android/repositories/rm11pro-canoe-dock/ports/orangefox-recovery/device_nubia_NX809J`
- Active remote: `https://github.com/Fractal-Echo/rm11pro-canoe-dock`
- Active subdir: `ports/orangefox-recovery/device_nubia_NX809J`
- Former standalone remote at import: `https://github.com/Fractal-Echo/rm11pro-orangefox-recovery`
- Former branch at import: `codex/nx809j-rm11pro-port`
- Former branch head at import: `023c9d6a5a2504bd3bf4eb7b656244d78ce68d0c`

Why this is not a byte-for-byte mirror:

- The source fork contains proprietary prebuilts and firmware payloads.
- The source fork contains AVB test key material.
- The dock repo is the public release/evidence hub and should not absorb large blobs or private key material as normal git history.

Copied:

- Text source/config required to understand the RM11 OrangeFox port.
- Local RM11 documentation and image-format forensics.
- Android 16 prebuilt README and manifest hashes.

Excluded:

- `keys/`
- `security/`
- `prebuilt/kernel`
- `prebuilt/dtbo.img`
- `prebuilt/android16/dtbo.img`
- `prebuilt/system/bin/`
- `prebuilt/android16/system/bin/`
- `prebuilt/android16/system/lib64/`
- `prebuilt/android16/vendor/bin/`
- `prebuilt/android16/vendor/lib64/`
- `recovery/root/vendor/bin/`
- `recovery/root/vendor/firmware/`
- `recovery/root/system/bin/busybox`
- `recovery/root/system/bin/dhcpcd`
- `recovery/root/system/bin/wpa_cli`
- binary `recovery/root/odm/etc/aac_richtap.config`
- all `*.img`, `*.zip`, `*.so`, `*.bin`, `*.elf`, `*.mdt`, and key-like payloads

Build note:

This dock snapshot is enough to audit the port logic and public documentation. A full recovery build still needs a hydrated OrangeFox source tree and the device prebuilts from the original working environment.
