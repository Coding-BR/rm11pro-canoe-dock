# Canoe Dock

RM11 Pro / REDMAGIC 11 Pro / NX809J root, GKI kernel, GSI/ROM, recovery, and module release hub.

The dock for RM11 Pro mods: unlock, root, KSU/SUSFS, AnyKernel3, GSI/ROM testing, recovery WIP, and modules.

`canoe` is the RM11 Pro platform reference seen in device evidence. `dock` is where validated release work, rollback notes, hashes, and public guides land. This is not a kernel source archaeology repo, an OrangeFox device-tree repo, or the custom source-kernel lab.

## Current Status

| Area | Current status |
|---|---|
| Bootloader unlock / fastboot / fastbootd | Documented access path |
| Magisk init_boot root | Confirmed |
| OP-WILD AnyKernel3 KSU/SUSFS | Validated test build |
| KernelSU-only root | Confirmed |
| GSI / ROM flow | WIP / reports |
| OrangeFox recovery | Build-pass / flash-pass / boot-fail / rollback-pass |
| Modules / RedMagic tools | WIP |

## NX809J Canoe Without A Paddle

> Files are not interchangeable across RM11 Pro, RM11 Air, RM10, RM10S, Astra / Pad 3 Pro, Z70U, Z80U, or other Nubia/ZTE devices. Do not flash ABL, vbmeta, init_boot, vendor_boot, boot, dtbo, recovery, or firmware images unless the file is confirmed for your exact model and firmware.

You are modifying Qualcomm boot-chain security. A wrong partition, wrong model, wrong slot, or mismatched AVB chain can break boot, route the device to fastboot/dumper mode, or require EDL recovery.

## Start Here

1. Read [Read This First](docs/00-read-this-first.md).
2. Confirm [Device Scope](docs/01-device-scope.md).
3. Prepare [Required Files](docs/02-required-files.md).
4. Disable OTA before going online: [OTA Disable](docs/03-ota-disable.md).
5. Back up critical partitions: [Backups And Privacy](docs/04-backups-and-privacy.md).

## Project Notes

Merged RM11 working notes live in [Project Notes](docs/project-notes/README.md). These are categorized maintainer notes for kernel building, recovery, GSI/ROM work, rooting, KernelSU/SuSFS, module testing, decryption, debloat/deodex, APK tooling, assets, and kernel-lab provenance.

OrangeFox RM10 Pro to RM11 Pro port evidence lives in [OrangeFox Port Notes](docs/orangefox-port/README.md). Raw recovery images, logs, and headers stay local under `/home/richtofen/android/repositories/MainAssets/recovery-forensics` and are summarized in tracked docs.

The curated OrangeFox device-tree source snapshot lives in [ports/orangefox-recovery](ports/orangefox-recovery/README.md).

## Release Policy

No artifact gets a stable label unless it has:

- Device/model confirmation.
- Firmware baseline.
- Artifact SHA-256.
- Source/provenance.
- Rollback images documented.
- Boot result.
- Reboot persistence result.
- Hardware smoke-test result.
- Idle/screen-off result.
- Known broken features.
- Recovery path.

## Known Release Lanes

- AnyKernel3 OP-WILD KSU/SUSFS: [validated test build](releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/README.md).
- OrangeFox recovery: [WIP only](releases/recovery/orangefox/README.md), with port evidence in [OrangeFox Port Notes](docs/orangefox-port/README.md).
- GSI/ROM reports: [reports only unless individually validated](releases/gsi-roms/README.md).
- Modules and tools: [optional and device-specific](releases/modules/README.md).

## Project Lineage

Canoe Dock consolidates RM11 Pro public release documentation from:

- The RM11 unlock/root/fastbootd community guide.
- The RM11 AnyKernel3 KernelSU-Next/SUSFS validation workspace.
- The RM11 OrangeFox recovery build and forensic evidence.
- The RM11 source-kernel lab, when evidence from that lab becomes release-relevant.
- Kernel lab source lineage includes [Coding-BR/android_kernel_nubia_sm8850_qwjujube](https://github.com/Coding-BR/android_kernel_nubia_sm8850_qwjujube), referenced as provenance rather than vendored into this dock.

Credits are tracked in [Project Lineage And Credits](docs/18-credits.md).
