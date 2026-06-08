# Verify

Before flashing:

```powershell
adb shell getprop ro.product.device
adb shell getprop ro.product.model
adb shell getprop ro.build.fingerprint
adb shell getprop ro.boot.slot_suffix
adb shell uname -a
```

Required pre-flash state:

- Device is RM11 Pro / NX809J.
- Android baseline is Android 16.
- Current kernel minor is `6.12.23`.
- Rollback images are present off-device.

After flash:

```powershell
adb wait-for-device
adb shell getprop sys.boot_completed
adb shell getprop ro.boot.slot_suffix
adb shell uname -a
adb shell cat /proc/version
adb shell su -c id
```

Expected known-good root output after Magisk removal/no longer active:

```text
uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0
```

Also check KernelSU-Next Manager:

- Working.
- Built-in GKI2.
- Version `33169`.
- Hook mode Inline / SuSFS.
