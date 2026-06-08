# OTA Disable

Before connecting to Wi-Fi or mobile data on a freshly prepared device, disable OTA services.

New OTA builds may patch unlock behavior, fastboot behavior, rollback expectations, or chained AVB assumptions.

Recommended first-boot sequence:

1. Complete Android setup offline.
2. Enable Developer Options.
3. Enable OEM Unlocking.
4. Enable USB Debugging.
5. Connect ADB.
6. Disable OTA services.

Commands:

```powershell
adb shell pm disable-user --user 0 com.zte.zdm
adb shell pm disable-user --user 0 com.zte.zdmdaemon
adb shell pm disable-user --user 0 com.zte.zdmdaemon.install
```

Only go online after backups and unlock/root planning are complete.
