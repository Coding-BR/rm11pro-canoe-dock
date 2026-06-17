# REDMAGIC 11 Pro / NX809J Canoe Dock: Unlock, Root, KernelSU, AnyKernel3, GSI & Recovery WIP

Project link placeholder:

```text
https://github.com/Fractal-Echo/rm11pro-canoe-dock
```

## Scope

This guide is for RM11 Pro / REDMAGIC 11 Pro / NX809J first.

Other devices such as RM11 Air, RM10, RM10S, Astra / Pad 3 Pro, Z70U, and Z80U are not file-compatible unless a file is explicitly documented for that exact model and firmware.

## Read This First

You are modifying Qualcomm boot-chain security. If you randomly flash partitions, skip backups, or mix firmware, you can break boot and require EDL recovery.

Do not flash ABL, vbmeta, init_boot, vendor_boot, boot, dtbo, recovery, or firmware images unless they are confirmed for your exact model and firmware.

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

## Required Files

- Current Android platform-tools.
- Google USB Driver on Windows.
- Qualcomm QDLoader driver.
- ZTE/Nubia toolbox version that supports your exact model.
- Stock firmware matching your exact firmware version.
- Engineering ABL only if confirmed for RM11 Pro / NX809J.
- Magisk for initial `init_boot` root.
- KernelSU-Next Manager for KSU/SUSFS validation.
- Rollback copies of critical partitions.

## Before Wi-Fi Or Mobile Data

Stay offline until OTA services are disabled.

```powershell
adb shell pm disable-user --user 0 com.zte.zdm
adb shell pm disable-user --user 0 com.zte.zdmdaemon
adb shell pm disable-user --user 0 com.zte.zdmdaemon.install
```

## Back Up Everything

Back up at minimum:

- `persist`
- `modemst1`
- `modemst2`
- `fsg`
- `init_boot`
- `boot`
- `vendor_boot`
- `vbmeta`
- `vbmeta_system`
- `recovery`

Store backups off-device. Never flash someone else's calibration partitions.

## Unlock Bootloader

Known community path uses the ZTE/Nubia toolbox EFISP unlock flow.

Start from booted Android if possible:

1. Enable OEM Unlocking and USB Debugging.
2. Connect ADB.
3. Run toolbox as Administrator.
4. Use the EFISP unlock option for supported devices.
5. Prefer the path where the toolbox reads Android device info first.
6. Follow EDL prompts.
7. Do not close the toolbox during cleanup.
8. Confirm unlocked state after reboot.
9. Back up unlocked state.

## Fastboot / Fastbootd

The current RM11 access path uses a confirmed RM11 Pro ABL reference from DevReverse/community research.

Do not flash ABL from another model or firmware family.

Driver test:

```powershell
fastboot devices
fastboot getvar unlocked
```

Fastbootd:

```powershell
fastboot reboot fastboot
fastboot devices
fastboot getvar is-userspace
```

Expected:

```text
is-userspace: yes
```

Use fastbootd for GSI and dynamic partition flashing.

## Chained AVB

Do not disable only one vbmeta layer and assume the rest of the chain is coherent.

Known community pattern:

```powershell
fastboot --disable-verity flash vbmeta_a vbmeta.img
fastboot --disable-verity flash vbmeta_b vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system_a vbmeta_system.img
fastboot --disable-verity --disable-verification flash vbmeta_system_b vbmeta_system.img
```

Use only exact-firmware or known-compatible vbmeta images.

## Root: Magisk init_boot

Patch your own matching `init_boot`.

Do not patch random uploads or images from another firmware version.

Proof:

```powershell
adb shell su -c id
```

Earlier RM11 validation proved Magisk shell root with:

```text
context=u:r:magisk:s0
```

## AnyKernel3 OP-WILD KSU/SUSFS

Validated test package:

```text
AK3-RM11-OPWILD.zip
```

SHA-256:

```text
7CAC8A90FD065FD2F31F8E1938ECE8F5BEA061CBD8213A03E44B86BA50EA1B4A
```

Validation:

- Boot after flash: PASS.
- Reboot persistence: PASS.
- Hardware smoke test: PASS.
- 20-minute idle/screen-off: PASS.
- KernelSU-Next Manager: Working / Built-in GKI2 / `v3.2.0 (33169)`.
- Hook mode: Inline / SuSFS.
- SUSFS initialized as `v2.1.0`.
- KSU-only shell root: PASS, `context=u:r:ksu:s0`.

This is for RM11 Pro / NX809J Android 16 kernel `6.12.23` baseline only.

## Magisk To KernelSU

Documented migration:

1. Start with Magisk root on matching `init_boot_a`.
2. Flash the validated AnyKernel3 KSU/SUSFS package to `boot_a`.
3. Confirm KernelSU-Next Manager shows Working / Built-in GKI2.
4. Confirm Inline / SuSFS.
5. Restore stock `init_boot_a`.
6. Grant Shell root through KernelSU-Next Manager.
7. Confirm:

```powershell
adb shell su -c id
```

Expected:

```text
uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0
```

## GSI / ROM Reports

Source guide reports Infinity X GSI, AOSP GSIs, and Pixel-based GSIs as working reports, with limitations around gaming features and the early kernel ecosystem.

Use fastbootd:

```powershell
fastboot reboot fastboot
```

Do not flash GSIs from normal bootloader fastboot.

## OrangeFox Recovery WIP

Current classification:

```text
build-pass / flash-pass / boot-fail / rollback-pass
```

Known facts:

- `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img` failed with `Bad Buffer Size`.
- `fastboot flash recovery_a` passed.
- Device routed to fastboot instead of recovery.
- Stock `recovery_a` rollback passed.
- Android boot was restored.

Forensic finding:

- Stock and OrangeFox are both Android boot image header v4 ramdisk-only recovery images.
- Stock recovery has signed `SHA256_RSA4096` recovery footer with rollback index `1`.
- Failed OrangeFox had `Algorithm: NONE`, rollback index `0`, and no auth block.
- AVBTEST1 uses a generated validation key, not the OEM key.

Recovery is not boot-proven. Do not tell users to flash it yet.

## If Fastboot Breaks

Usually caused by incompatible partitions, wrong AVB handling, wrong slot, or firmware mixing.

Restore stock backups, known-good ABL, original `init_boot`, original `vendor_boot`, and original vbmeta chain.

## Credits

- `@SYXZ` / ZTE Family Toolbox community.
- `@dev-reverse`.
- `@Haldi4803`.
- `@sam595`.
- `@alejandroprz95`.
- `@c3c3`.
- `@EliteBlackKaiser`.
- `@AdaUnlocked`.
- WildKernel OP-WILD KSU/SUSFS upstream.
- KernelSU-Next.
- SUSFS.
- Magisk.
- OrangeFox.
- Droidspaces reference artifacts.
- Fractal-Echo/RM11 lab work.

If you test, document the exact artifact hash, firmware baseline, slot, command output, broken features, and rollback result.
