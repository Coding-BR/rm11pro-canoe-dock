# Next Actions

## Immediate

1. Keep `rm11pro-canoe-dock` as the public dock, not a raw lab dump.
2. Keep raw recovery forensics in `/home/richtofen/android/repositories/MainAssets/recovery-forensics`; dock keeps summaries and a pointer README only.
3. Re-clone the upstream kernel tree only when kernel-source work resumes; the broken local checkout was deleted after notes were summarized.
4. Add an image identity table for every boot/recovery/kernel image before further testing.

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

Do not label OrangeFox usable.

Next recovery work, only if intentionally testing:

- verify stock rollback images.
- test AVBTEST1 cautiously.
- record slot/hash/command/result.
- stop if it routes to fastboot again.

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

## Public Docs

Useful next doc cleanup for `rm11pro-canoe-dock`:

- Add stronger kernel fork "developer research only" disclaimer.
- Keep OrangeFox WIP warning.
- Add GSI report matrix.
- Add module provenance rule.
- Add recovery decryption checklist once recovery boots.
