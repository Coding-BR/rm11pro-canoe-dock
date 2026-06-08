# Read This First

Canoe Dock is for RM11 Pro / REDMAGIC 11 Pro / NX809J first.

You are modifying Qualcomm boot-chain security. If you randomly flash partitions, skip backups, or mix files across devices, you can break boot and force EDL recovery.

Hard rules:

- Do not mix files across RM11 Pro, RM11 Air, RM10, RM10S, Astra / Pad 3 Pro, Z70U, Z80U, or other Nubia/ZTE devices.
- Do not flash ABL, vbmeta, init_boot, vendor_boot, boot, dtbo, recovery, or firmware images unless the file is confirmed for your exact model and firmware.
- Do not publish an artifact without hashes, provenance, verification steps, and rollback notes.
- Do not call recovery usable until it actually boots recovery UI and basic recovery functions pass.
- Keep rollback files off-device before testing.

Minimum proof before trusting a result:

```powershell
adb shell getprop ro.product.device
adb shell getprop ro.boot.slot_suffix
adb shell uname -a
adb shell getprop sys.boot_completed
```
