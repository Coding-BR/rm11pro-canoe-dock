# RM11 Pro OrangeFox Flash Pass / Boot Fail / Rollback Pass

Date: 2026-06-07

## Summary

The RM11 Pro / RedMagic 11 Pro OrangeFox build artifact flashed successfully to `recovery_a`, but the device could not boot OrangeFox recovery. Recovery boot routed back to fastboot. Restoring the stock `recovery_a` image succeeded and Android boot was restored.

This evidence changes the OrangeFox status from build-only to:

`build-pass / flash-pass / boot-fail / rollback-pass`

Do not publish this image. Do not retest the same image until recovery image format, header, partition, and boot-chain assumptions are fixed.

## Artifact Tested

```text
OrangeFox-R12.0-Unofficial-NX809J.img
```

Known build hash:

```text
ff2b9de6ee69e96d1aa41722bae39bd4960dd8f374c8d7ba72a61ba5ae25028d  OrangeFox-R12.0-Unofficial-NX809J.img
```

Known image size:

```text
104857600 bytes
```

Known RM11 recovery partition size:

```text
104857600 bytes
```

## Observed Result

- `fastboot boot` attempt: FAIL
- `fastboot boot` error: `Bad Buffer Size`
- `fastboot flash recovery_a`: PASS
- Boot to OrangeFox recovery after flash: FAIL
- Device behavior after failed recovery boot: routed to fastboot
- Stock `recovery_a` rollback flash: PASS
- Android boot after rollback: PASS

## Interpretation

The image is buildable and flashable to the expected recovery partition, but it is not bootable on the device in its current form.

The `fastboot boot` failure with `Bad Buffer Size` and the flashed recovery boot failure point to unresolved recovery image format, header, partition, or boot-chain assumptions. The current build should not be treated as an OrangeFox functional validation.

## Current Classification

```text
Build: PASS
Flash to recovery_a: PASS
Boot to recovery: FAIL
Rollback: PASS
Android restored: PASS
```

Do not call this image usable, stable, release-ready, or device-safe.

## Required Before Retesting

Do not retest this same image. Fix and rebuild first.

Required investigation areas:

- Verify RM11 recovery partition image format expectations.
- Verify boot header assumptions for standalone recovery on this device.
- Compare stock `recovery_a.img` header and ramdisk layout against the OrangeFox output.
- Confirm whether RM11 expects recovery resources through `vendor_boot`, `init_boot`, or another boot-chain component.
- Confirm whether the generated image being exactly partition-sized is acceptable or masking an image construction problem.
- Rebuild with corrected assumptions and a new hash before any further flash attempt.

## Rollback Status

Rollback to stock `recovery_a` succeeded and Android boot was restored.

This rollback pass is important evidence that the recovery partition can be restored, but it does not make the failed OrangeFox image safe to keep testing.
