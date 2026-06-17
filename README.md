# Canoe Dock

RM11 Pro / REDMAGIC 11 Pro / NX809J root, GKI kernel, GSI/ROM, recovery, and module release hub.

The dock for RM11 Pro mods: unlock, root, KSU/SUSFS, AnyKernel3, GSI/ROM testing, recovery baselines, and modules.

`canoe` is the RM11 Pro platform reference seen in device evidence. `dock` is where validated release work, rollback notes, hashes, and public guides land. This is not a kernel source archaeology repo, an OrangeFox device-tree repo, or the custom source-kernel lab.

Route 1 safe public CI is merged to `main`. Public GitHub Actions verify recovery, AnyKernel3, APK, and module lanes, with one experimental OrangeFox build/release workflow for NX809J recovery artifacts. D2N is the current RM11 Pro NX809J/canoe recovery baseline, not a universal stable guarantee across every firmware or local modification state.

An experimental GitHub Actions workflow can sync OrangeFox 14.1, build the current NX809J recovery tree, and update the single fixed prerelease `orangefox-nx809j-latest`. A generated release proves only that the image built in CI; it does not prove recovery boot, UI, ADB, touch, MTP, decryption, ZIP flashing, backup/restore, fastbootd, or USB OTG on a real device.

## Current Status

| Area | Current status |
|---|---|
| Bootloader unlock / fastboot / fastbootd | Documented access path |
| Magisk init_boot root | Confirmed |
| OP-WILD AnyKernel3 KSU/SUSFS | Validated test build |
| KernelSU-only root | Confirmed |
| GSI / ROM flow | WIP / reports |
| OrangeFox recovery | Current short-name test package plus D2N fallback baseline |
| AnyKernel3 / APK / module lanes | AnyKernel3 Droidspace prebuilt; APK/module verifier lanes staged |
| Modules / RedMagic tools | WIP / verifier lane staged |

## Current Downloads

Short public names are used for files people are expected to download:

| Lane | File | Status |
|---|---|---|
| OrangeFox recovery current test | [OrangeFox-RM11.zip](releases/recovery/orangefox/current/OrangeFox-RM11.zip) | v4 RM11 theme/splash test image, boots recovery in local visual test |
| OrangeFox recovery fallback | [OrangeFox-RM11-D2N.zip](releases/recovery/orangefox/d2n/OrangeFox-RM11-D2N.zip) | D2N functional recovery baseline |
| AnyKernel3 Goldbug test | [AK3-RM11-Goldbug.zip](releases/anykernel/goldbug/AK3-RM11-Goldbug.zip) | guarded experimental kernel package |

The raw `recovery.img` is not committed separately because it is exactly
`104857600` bytes. The OrangeFox zip contains `recovery.img`.

## Current Baseline

- Route 1 safe public CI: merged to `main`.
- Tag: `recovery-route1-d2n-baseline-2026-06-15`.
- Merge commit: `83bdd11786e92c24a94eb2b7e696f80324c810d7`.
- D2N recovery image SHA256: `a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0`.
- D2N recovery zip SHA256: `5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab`.
- Current RM11 test recovery image SHA256: `b3c0cdeb3efbedf0903eced3a840523fe735ec27082c9f1f2bd826884166187f`.
- Current RM11 test recovery zip SHA256: `f2547c3ff9d43b060ba0ece1e9f497e2de0fbe0180a6eb8bdde3df01d80ce0d3`.
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

## Flash OrangeFox After Unlock

These steps start after bootloader unlock. They assume the device is RM11 Pro /
REDMAGIC 11 Pro / NX809J (`canoe`) and Android can still boot.

Fastboot on this device depends on the correct RM11 Pro ABL path. If you skip
the ABL step, `fastboot devices` may hang or never expose usable partition
flashing. Do not flash ABL from any other device, firmware family, or forum
post.

1. Back up the stock boot chain first:

```powershell
adb devices
adb shell getprop ro.product.model
adb shell getprop ro.product.device
adb shell getprop ro.boot.slot_suffix
```

Expected device identity:

```text
model: REDMAGIC 11 Pro or NX809J
device: NX809J, sm88XX, or canoe evidence path
slot: _a or _b
```

2. Flash the known-good RM11 Pro ABL using the same EDL/toolbox partition-write
   flow used for unlock. This is not a fastboot step, because fastboot is what
   the ABL fix enables.

```text
target partitions: abl_a and abl_b
file: your verified RM11 Pro/NX809J ABL image
```

After writing ABL, reboot to bootloader and confirm fastboot works:

```powershell
fastboot devices
fastboot getvar product
fastboot getvar current-slot
fastboot getvar partition-size:recovery_a
fastboot getvar partition-size:recovery_b
```

Expected:

```text
product: canoe
current-slot: a or b
partition-size:recovery_a: 0x6400000
partition-size:recovery_b: 0x6400000
```

3. Extract `recovery.img` from `OrangeFox-RM11.zip` and verify it before
   flashing:

```powershell
Expand-Archive .\OrangeFox-RM11.zip -DestinationPath .\OrangeFox-RM11
Get-FileHash .\OrangeFox-RM11\recovery.img -Algorithm SHA256
```

Expected for the current RM11 theme/splash test image:

```text
b3c0cdeb3efbedf0903eced3a840523fe735ec27082c9f1f2bd826884166187f
```

4. Flash one recovery slot only. Start with `recovery_a` unless you have a
   specific reason to test the other slot.

```powershell
fastboot flash recovery_a .\OrangeFox-RM11\recovery.img
fastboot reboot recovery
```

5. Keep a rollback image ready before testing:

```powershell
fastboot flash recovery_a .\stock-recovery-a.img
fastboot reboot recovery
```

Stop immediately if `fastboot getvar product` is not `canoe`, if the recovery
partition size is not `0x6400000`, or if the recovery image hash does not match
the published hash.

## Project Notes

Merged RM11 working notes live in [Project Notes](docs/project-notes/README.md). These are categorized maintainer notes for kernel building, recovery, GSI/ROM work, rooting, KernelSU/SuSFS, module testing, decryption, debloat/deodex, APK tooling, assets, and kernel-lab provenance.

OrangeFox RM10 Pro to RM11 Pro port evidence lives in [OrangeFox Port Notes](docs/orangefox-port/README.md). Raw recovery images, logs, and headers stay local under `<local-build-root>/recovery-forensics` and are summarized in tracked docs.

The curated OrangeFox device-tree source snapshot lives in [recovery](recovery/README.md), with the active device tree at `recovery/device/zte/sm88XX`.

Experimental OrangeFox build artifacts are published from the Actions workflow only when the public runner has enough disk to complete the sync and build. The workflow updates only the fixed `orangefox-nx809j-latest` release and replaces previous assets instead of accumulating automatic releases. Treat those artifacts as test candidates and flash only with stock recovery rollback ready.

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

- AnyKernel3 OP-WILD KSU/SUSFS: current DroidSpaces runtime lane documented in [AnyKernel releases](releases/anykernel/README.md).
- AnyKernel3 Goldbug: guarded experimental package in [AnyKernel releases](releases/anykernel/README.md).
- OrangeFox recovery: current short-name prebuilt in [Recovery releases](releases/recovery/README.md), source lane in [recovery](recovery/README.md).
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
