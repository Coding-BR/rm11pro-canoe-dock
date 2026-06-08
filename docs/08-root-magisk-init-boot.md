# Root: Magisk init_boot

Initial RM11 Pro root path uses Magisk on matching `init_boot`.

Rules:

- Patch your own `init_boot` image.
- Do not patch random uploads.
- Do not patch images from another firmware version.
- Keep stock `init_boot_a.img` before flashing the patched image.

High-level flow:

1. Extract or back up matching stock `init_boot`.
2. Patch with Magisk.
3. Flash through the safest available path for your current device state.
4. Boot Android.
5. Confirm root.

Proof:

```powershell
adb shell su -c id
```

Earlier RM11 validation confirmed Magisk root before migration:

```text
uid=0(root) gid=0(root) groups=0(root) context=u:r:magisk:s0
```

Current validated state has moved to KernelSU-only shell root; see [Magisk To KernelSU](11-magisk-to-kernelsu.md).
