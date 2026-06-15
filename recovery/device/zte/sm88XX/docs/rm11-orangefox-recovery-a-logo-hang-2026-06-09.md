# RM11 OrangeFox recovery_a Logo-Hang Test - 2026-06-09

## Result

The OrangeFox candidate built from the NX809J device tree was written only to
`recovery_a` and verified byte-for-byte, then booted with `adb reboot recovery`.
The device reached the RedMagic logo and did not reach recovery UI or recovery
ADB.

Android remained recoverable by force reboot. `recovery_a` was restored from
the pre-test stock backup and verified against `recovery_b`.

## Device State

- Device: REDMAGIC 11 Pro / NX809J / canoe
- Active slot during test: `_a`
- recovery_a partition size: `104857600`
- recovery_b partition size: `104857600`
- Candidate image size: `104857600`
- Candidate image hash:
  `af27bb5e9d4d094973984392b3aaf32e403d87a0ecd66cf2b769d682933cab86`
- Restored stock recovery hash:
  `694eba1214ff90f1da496c2108e98479167b15f3f7eb631deb64493402303394`

## Confirmed Constraints

- Standard `fastboot boot` is not a useful recovery test path on this device.
- The stock and OrangeFox recovery images are ramdisk-only header-v4 recovery
  partition images with `kernel_size: 0`.
- The failed candidate was not proven to reach recovery userspace, ADB, touch,
  MTP, or decryption.

## First Corrective Patch Direction

The failed OrangeFox ramdisk differed from stock in two early-boot surfaces:

- `system/etc/recovery.fstab` used a vendor_boot-derived layout with EROFS
  alternates, extra AVB key chains, and physical boot partitions marked for
  first-stage mount.
- `init.recovery.qcom.rc` started or manipulated decryption, keymint, vendor
  health, vibrator/touch, firmware, fan, and LED paths before recovery UI was
  proven.

For the next build, keep those surfaces close to the restored stock
`recovery_a` ramdisk:

- use the stock-derived recovery fstab;
- use the stock-minimal qcom init hook;
- defer decryption, touchscreen, haptics, fan, and LED services until the image
  reaches recovery UI or recovery ADB.
