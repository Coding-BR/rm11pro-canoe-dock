# Next Actions

## Immediate

1. Keep `rm11pro-canoe-dock` as the public dock, not a raw lab dump.
2. Keep raw recovery forensics in `<local-build-root>/recovery-forensics`; dock keeps summaries and a pointer README only.
3. Treat D2N as the current OrangeFox recovery baseline, while still keeping
   operation-specific tests separate.
4. Re-clone or fetch heavy kernel/GPU/container trees only when their lane is
   active.
5. Add an image identity table for every boot/recovery/kernel image before
   further flashing.

## Kernel

Next kernel test should be the minimal blue-dump-on-wake evidence bundle, not a new broad patch.

Collect:

- image SHA256.
- boot command.
- slot.
- runtime marker.
- boot result.
- wake result.
- touch result.
- pstore/ramoops result.
- exact evidence folder.

Classify result:

- display/panel/DSI/SDE -> panel resume path.
- DTB/bootconfig/vendor_boot/init_boot/FDT -> packaging path.
- `zte_tpd`, `syna`, touch IRQ, `tpd_resume` -> touch/module path.
- no logs -> fix capture path first.

## Recovery

D2N is the current recovery baseline for the lab.

Next recovery work, only if intentionally testing operations:

- MTP.
- fastbootd.
- backup/restore.
- ZIP install.
- image flash from UI.
- wipe/format paths.
- USB OTG.
- reboot-menu behavior.
- one-slot first for any new recovery image.

## Root/KSU

Keep Magisk init_boot, KSU/SuSFS, and kernel RAM boot as separate test lanes.

Do not mix:

- init_boot root flashing.
- boot image RAM boot.
- vendor_dlkm/module replacement.
- recovery flashing.

## GSI/ROM

Turn future GSI claims into a matrix:

- firmware.
- GSI build.
- flash path.
- root state.
- working/broken features.
- rollback.

## Droidspace / Containers

Recovery is no longer the active blocker, so start with a read-only Android
state snapshot and the Droidspaces checker before importing rootfs payloads.

Order:

1. Sync/fetch the small core Droidspace stack.
2. Build/install only debug/test APKs first.
3. Run kernel/root/SELinux checks.
4. Test minimal rootfs before KDE.
5. Add Termux:X11, then audio, then GPU.
6. Defer Winlator, Mesa, VirtualAP, and recovery-boot-container experiments
   until the base Linux lane passes.

## Public Docs

Useful next doc cleanup for `rm11pro-canoe-dock`:

- Add stronger kernel fork "developer research only" disclaimer.
- Keep D2N baseline warning scoped to untested operations.
- Add GSI report matrix.
- Add module provenance rule.
- Add recovery operation checklist after MTP/backup/install/wipe testing.
