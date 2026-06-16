# RM11 Pro Post-KernelSU Live ADB Sanity

Evidence source: connected REDMAGIC 11 Pro / NX809J running Android 16 after the OP-WILD `6.12.23` KernelSU-Next/SUSFS AnyKernel3 validation, captured on 2026-06-07.

This is not a recovery boot validation. It records the current live Android state after the kernel/root validation so the older Magisk baseline remains clearly historical.

## State

| Key | Value |
|-----|-------|
| Active slot | `_a` |
| Android boot completed | `1` |
| Kernel | `6.12.23-android16-OP-WILD` |
| Shell root provider | KernelSU |
| Shell root context | `u:r:ksu:s0` |
| KernelSU Next Manager package | `com.rifsxd.ksunext` |
| KernelSU Next Manager version | `v3.1.0` / `33024` |

## Observed Commands

```bash
adb get-state
adb shell getprop ro.boot.slot_suffix
adb shell getprop sys.boot_completed
adb shell uname -a
adb shell su -c id
adb shell dumpsys package com.rifsxd.ksunext
```

## Observed Output

```text
device
_a
1
Linux localhost 6.12.23-android16-OP-WILD #1 SMP PREEMPT Sat Jun  6 15:12:15 UTC 2026 aarch64 Toybox
uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0
versionCode=33024 minSdk=26 targetSdk=36
versionName=v3.1.0
```

## Recovery Relevance

- The Android-side root path is now KernelSU-only, not Magisk shell root.
- The device is still online and boot-complete on slot `_a`.
- This does not prove OrangeFox recovery boot, touch, ADB, decryption, or fastbootd.
- First recovery boot logs are still required before marking any recovery feature as validated.
