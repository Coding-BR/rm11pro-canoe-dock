# GSI And ROM Building

## Status

GSI/ROM work is a report lane, not a stable release lane yet.

`rm11pro-canoe-dock` already has the right public stance:

- GSI reports are reports unless each build has its own validation page.
- Use fastbootd for GSI/dynamic partition work.
- Do not flash GSIs from normal bootloader fastboot.

## Current Reports

Source guide/repo mentions:

- Infinity X GSI.
- AOSP GSIs.
- Pixel-based GSIs.

Known limitations:

- Gaming features may be partially broken.
- Kernel ecosystem is early.
- Recovery is not boot-proven.
- GSI success must be reported per build, not as universal compatibility.

## Required GSI Report Fields

Every GSI report should include:

- Device model: RM11 Pro / NX809J.
- Stock firmware version.
- Slot.
- Toolbox/ABL state.
- ABL source/hash if relevant.
- vbmeta/vbmeta_system handling.
- GSI name/version/date.
- Exact flash commands.
- Boot result.
- Hardware result.
- Broken RedMagic features.
- Root state.
- Rollback result.

## ROM Building Practical Model

ROM work depends on a stable access and boot-chain base:

1. Preserve stock and rooted rollback images.
2. Keep fastboot/fastbootd access documented.
3. Keep kernel experiments separate from ROM experiments.
4. Use image identity tables before claiming a ROM/kernel result.
5. Move public reports into `rm11pro-canoe-dock` only after validation.

## Current Assets

Relevant local paths:

- `/mnt/e/Android/RM-11-Pro/BOOT/GSI/`
- `/mnt/e/Android/RM-11-Pro/BOOT/XX-Dev-Rom/`
- `/mnt/e/Android/RM-11-Pro/staging-notes/ROM_GSI_BUILDING.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/ROM_MAKING_USEFUL_KEEPERS.md`

Large asset warning:

- `/mnt/e/Android/RM-11-Pro/BOOT/XX-Dev-Rom/super.img` is very large. Do not copy it into git.

## What Helps Canoe Dock

Promote:

- GSI report template.
- Validated GSI matrix.
- rollback notes.
- fastbootd warning.

Do not promote:

- raw `super.img`.
- private calibration partitions.
- "GSI works" claims without build/date/firmware.

## Source References

- `<repo-root>/docs/12-gsi-rom-flow.md`
- `<repo-root>/releases/gsi-roms/README.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/ROM_GSI_BUILDING.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/ROM_MAKING_USEFUL_KEEPERS.md`
