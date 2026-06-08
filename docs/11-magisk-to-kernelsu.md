# Magisk To KernelSU

Documented transition path:

1. Start with Magisk root on matching `init_boot_a`.
2. Flash the validated AnyKernel3 KSU/SUSFS package to `boot_a`.
3. Boot Android.
4. Confirm KernelSU-Next Manager shows Working / Built-in GKI2.
5. Confirm Inline / SuSFS hook mode.
6. Restore stock `init_boot_a` to remove Magisk shell root.
7. Grant Shell root through KernelSU-Next Manager.
8. Confirm root context.

Command:

```powershell
adb shell su -c id
```

Expected:

```text
uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0
```

That output confirms shell root is being provided under the KernelSU SELinux context rather than Magisk.
