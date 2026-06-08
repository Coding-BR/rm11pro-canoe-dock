# OrangeFox Rollback

Before any recovery test, keep stock `recovery_a.img` off-device.

If recovery flash fails to boot or routes to fastboot, restore stock recovery:

```powershell
fastboot flash recovery_a recovery_a_stock_before_orangefox.img
fastboot reboot
```

After Android boots:

```powershell
adb wait-for-device
adb shell getprop sys.boot_completed
adb shell getprop ro.boot.slot_suffix
```

Do not continue recovery testing until rollback is confirmed.
