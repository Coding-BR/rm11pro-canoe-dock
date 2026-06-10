# OrangeFox Rollback

Before any recovery test, keep stock `recovery_a.img` and `recovery_b.img`
off-device.

Do not assume standard `fastboot boot` or `fastboot flash recovery` is a useful
RM11 recovery test path.

If recovery test fails but Android still boots, restore only the tested slot
from rooted Android:

```powershell
adb push C:\temp\nx809j-recovery-backup\recovery_a-before-orangefox.img /sdcard/recovery_a-restore.img
adb shell su -c 'dd if=/sdcard/recovery_a-restore.img of=/dev/block/bootdevice/by-name/recovery_a bs=4M status=progress'
adb shell su -c 'sync'
adb reboot
```

After Android boots:

```powershell
adb wait-for-device
adb shell getprop sys.boot_completed
adb shell getprop ro.boot.slot_suffix
```

Do not continue recovery testing until rollback is confirmed.

For a first RM11 recovery test, write only the active slot. Do not write both
`recovery_a` and `recovery_b` until recovery UI, ADB, touch, MTP, decryption
expectations, and reboot-to-system have been checked.
