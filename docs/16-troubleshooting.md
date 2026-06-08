# Troubleshooting

## Fastboot Breaks

Usually caused by:

- Incorrect AVB handling.
- Incompatible partitions.
- Random firmware mixing.
- Wrong slot.
- Driver mismatch.

Restore:

- Stock backups.
- Known-good ABL.
- Original `init_boot`.
- Original `vendor_boot`.
- Original `boot`.
- Original vbmeta chain.

## Fastboot Driver Hangs

If fastboot waits forever:

```text
< waiting for any device >
```

Install Google USB Driver manually and select Android Bootloader Interface.

## Blue Screen / Dumper Mode

The source guide notes toolbox recovery/reset options may be needed when the device enters dumper state. Treat this as a recovery path, not a normal workflow. It may wipe data.

## Proof Capture

Capture command output before and after changes:

```powershell
adb shell getprop ro.product.device
adb shell getprop ro.boot.slot_suffix
adb shell uname -a
adb shell getprop sys.boot_completed
fastboot getvar current-slot
fastboot getvar unlocked
```
