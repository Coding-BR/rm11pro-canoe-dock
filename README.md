# Canoe Dock

RM11 Pro / REDMAGIC 11 Pro / NX809J root, GKI kernel, GSI/ROM, recovery, and module release hub.

The dock for RM11 Pro mods: unlock, root, KSU/SUSFS, AnyKernel3, GSI/ROM testing, recovery baselines, and modules.

`canoe` is the RM11 Pro platform reference seen in device evidence. `dock` is where validated release work, rollback notes, hashes, and public guides land. This is not a kernel source archaeology repo, an OrangeFox device-tree repo, or the custom source-kernel lab.

Route 1 safe public CI is merged to `main`. Public GitHub Actions are verifier-only for recovery, AnyKernel3, APK, and module lanes; full OrangeFox builds remain local/fork-owner controlled. D2N is the current RM11 Pro NX809J/canoe recovery baseline, not a universal stable guarantee across every firmware or local modification state.

## Current Status

| Area | Current status |
|---|---|
| Bootloader unlock / fastboot / fastbootd | Documented access path |
| Magisk init_boot root | Confirmed |
| OP-WILD AnyKernel3 KSU/SUSFS | Validated test build |
| KernelSU-only root | Confirmed |
| GSI / ROM flow | WIP / reports |
| OrangeFox recovery | D2N current NX809J/canoe baseline |
| AnyKernel3 / APK / module lanes | AnyKernel3 Droidspace prebuilt; APK/module verifier lanes staged |
| Modules / RedMagic tools | WIP / verifier lane staged |

## Current Baseline

- Route 1 safe public CI: merged to `main`.
- Tag: `recovery-route1-d2n-baseline-2026-06-15`.
- Merge commit: `83bdd11786e92c24a94eb2b7e696f80324c810d7`.
- D2N recovery image SHA256: `a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0`.
- D2N recovery zip SHA256: `5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab`.
- Build policy: public CI verifies layout, scripts, hashes, and safety constraints only; full OrangeFox builds stay local/fork-owner controlled.

## NX809J Canoe Without A Paddle

> Files are not interchangeable across RM11 Pro, RM11 Air, RM10, RM10S, Astra / Pad 3 Pro, Z70U, Z80U, or other Nubia/ZTE devices. Do not flash ABL, vbmeta, init_boot, vendor_boot, boot, dtbo, recovery, or firmware images unless the file is confirmed for your exact model and firmware.

You are modifying Qualcomm boot-chain security. A wrong partition, wrong model, wrong slot, or mismatched AVB chain can break boot, route the device to fastboot/dumper mode, or require EDL recovery.

## Recovery / TWRP Safety

> [!CAUTION]
> Do not try to fix or change the device fingerprint after using TWRP or OrangeFox recovery.

> [!CAUTION]
> Do not install TWRP or OrangeFox while Magisk or KernelSU modules are active.

The `abl_unlock.elf` userdebug ABL file is included in this repository. It can be flashed with ZTE Toolbox to make fastboot access easier.

To enable fastboot with ZTE Toolbox:

1. Open ZTE Toolbox.
2. Select option `12`.
3. Enter the target ABL partition name: `abl_a` or `abl_b`.
4. Flash the included `abl_unlock.elf` userdebug ABL.
5. Reboot the phone into fastboot:

```shell
adb reboot bootloader
```

You can also flash recovery directly with ZTE Toolbox:

1. Select option `12`.
2. Enter the target recovery partition name: `recovery_a` or `recovery_b`.
3. Repeat the same step for the other recovery slot if you want to flash both `recovery_a` and `recovery_b`.

Manual fastboot recovery commands:

```shell
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
```

For GSI ROM installation, disable verity and verification on the vbmeta partitions from fastboot:

```shell
fastboot --disable-verity flash vbmeta_a vbmeta.img
fastboot --disable-verity flash vbmeta_b vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system_a vbmeta_system.img
fastboot --disable-verity --disable-verification flash vbmeta_system_b vbmeta_system.img
```

If the phone enters a bootloop after installation, open ZTE Toolbox and select option `19`.

## Start Here

1. Read [Read This First](docs/00-read-this-first.md).
2. Confirm [Device Scope](docs/01-device-scope.md).
3. Prepare [Required Files](docs/02-required-files.md).
4. Disable OTA before going online: [OTA Disable](docs/03-ota-disable.md).
5. Back up critical partitions: [Backups And Privacy](docs/04-backups-and-privacy.md).

## Project Notes

Merged RM11 working notes live in [Project Notes](docs/project-notes/README.md). These are categorized maintainer notes for kernel building, recovery, GSI/ROM work, rooting, KernelSU/SuSFS, module testing, decryption, debloat/deodex, APK tooling, assets, and kernel-lab provenance.

OrangeFox RM10 Pro to RM11 Pro port evidence lives in [OrangeFox Port Notes](docs/orangefox-port/README.md). Raw recovery images, logs, and headers stay local under `<local-build-root>/recovery-forensics` and are summarized in tracked docs.

The curated OrangeFox device-tree source snapshot lives in [recovery](recovery/README.md), with the active device tree at `recovery/device/zte/sm88XX`.

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

- AnyKernel3 Droidspace Goldbug guarded: prebuilt package in [AnyKernel releases](releases/anykernel/README.md).
- AnyKernel3 OP-WILD KSU/SUSFS: verifier lane staged in [AnyKernel3](anykernel3/README.md), older release notes are being reconciled before publication.
- OrangeFox recovery: D2N prebuilt in [Recovery releases](releases/recovery/README.md), source lane in [recovery](recovery/README.md).
- APKs: verifier lane staged in [APKs](apks/README.md).
- Modules and tools: verifier lane staged in [Modules](modules/README.md).
- Droidspaces/container work: paused lane in [Container](container/README.md).

## Project Lineage

Canoe Dock consolidates RM11 Pro public release documentation from:

- The RM11 unlock/root/fastbootd community guide.
- The RM11 AnyKernel3 KernelSU-Next/SUSFS validation workspace.
- The RM11 OrangeFox recovery build and forensic evidence.
- The RM11 source-kernel lab, when evidence from that lab becomes release-relevant.
- Kernel lab source lineage includes [Coding-BR/android_kernel_nubia_sm8850_qwjujube](https://github.com/Coding-BR/android_kernel_nubia_sm8850_qwjujube), referenced as provenance rather than vendored into this dock.

Credits are tracked in [Project Lineage And Credits](docs/18-credits.md).
