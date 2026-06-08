# Device / Variant Scope

Primary target:

- RM11 Pro / REDMAGIC 11 Pro / NX809J.
- Android 16 baseline.
- Platform reference: `canoe`.

Known non-targets unless explicitly documented:

- RM11 Air.
- RM10 / RM10 Pro / RM10S.
- Astra / Pad 3 Pro.
- Z70U.
- Z80U.
- Other Nubia/ZTE devices.

Those devices may share community tooling or adjacent research, but that is not file compatibility. Treat each partition image as model-specific and firmware-specific.

Before flashing anything, capture:

```powershell
adb shell getprop ro.product.device
adb shell getprop ro.product.model
adb shell getprop ro.build.fingerprint
adb shell getprop ro.boot.slot_suffix
adb shell uname -a
```
