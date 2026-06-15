# RM11 OrangeFox Stock-Fstab / Minimal-Init Test Candidate - 2026-06-09

## Status

Classification:

```text
build-pass / not-device-tested / one-slot-cautious-candidate
```

This is the next local OrangeFox recovery candidate after the 2026-06-09
`recovery_a` test hung at the RedMagic logo and stock recovery was restored.

## Why This Candidate Exists

The failed image differed from stock standalone recovery in early boot-critical
files:

- `system/etc/recovery.fstab` used a vendor_boot-style layout with EROFS
  alternates, extra AVB key chains, and physical boot/init_boot/vendor_boot/dtbo
  partitions marked as first-stage mounts.
- `init.recovery.qcom.rc` started or manipulated decryption, keymint, vendor
  health, vibrator/touch, firmware, fan, and LED paths before recovery UI or
  recovery ADB was proven.

The current patch intentionally moves those surfaces closer to the restored
stock `recovery_a` ramdisk:

- `recovery/device/zte/sm88XX/recovery.fstab`
- `recovery/device/zte/sm88XX/recovery/root/init.recovery.qcom.rc`

## Local Artifact

The artifact is intentionally not committed.

```text
/home/richtofen/.android/repositories/MainAssets/fox_14.1/out/target/product/NX809J/OrangeFox-R12.0-Unofficial-NX809J.img
```

Windows temp copy:

```text
C:\temp\orangefox-nx809j-stockfstab-mininit-20260609.img
```

SHA-256:

```text
9a3d822bbe8201321934a3e746b6c2efc6ef4c037939a858e94487fd866e2d4d
```

Size:

```text
104857600 bytes
```

Image format:

- Android boot image header v4.
- `kernel_size: 0`.
- Ramdisk-only recovery partition image.
- Recovery partition sized, not directly RAM-bootable with `fastboot boot`.
- AVB footer present with `SHA256_RSA4096`, rollback index `1`, location `0`.
- Uses a generated validation key, not the stock/OEM recovery key.

## Build Command

Current local-build lane:

```bash
cd /home/richtofen/.android/repositories/rm11pro-canoe-dock
./scripts/local-build/build-orangefox-nx809j-local.sh --env scripts/local-build/env-orangefox-nx809j.local
```

Historical one-off helper:

```bash
scripts/local-build/build-orangefox-test-candidate-legacy.sh
```

## Pre-Test Verification

From PowerShell:

```powershell
cd \\wsl.localhost\Ubuntu\home\richtofen\android\repositories\rm11pro-canoe-dock
.\scripts\verify-recovery-image.ps1 -ImagePath C:\temp\orangefox-nx809j-stockfstab-mininit-20260609.img
```

## Device-Side Test Rule

Do not test this by `fastboot boot`.

Do not write both recovery slots first.

If a device-side test is intentionally approved, use rooted Android to backup
both recovery slots, push the verified candidate, write only active
`recovery_a`, then `adb reboot recovery`.

If it hangs or fails, force reboot Android and restore the saved
`recovery_a-before-orangefox.img` with rooted Android `dd`.
