# KernelSU Next And SuSFS

## Status

Validated public dock lane:

- OP-WILD AnyKernel3 KSU/SUSFS package.
- RM11 Pro / NX809J only.
- Android 16.
- Kernel baseline `6.12.23`.

Known package:

```text
AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0_TEST.zip
```

SHA256:

```text
7CAC8A90FD065FD2F31F8E1938ECE8F5BEA061CBD8213A03E44B86BA50EA1B4A
```

Validation state from `rm11pro-canoe-dock`:

- Boot after flash: PASS.
- Reboot persistence: PASS.
- Hardware smoke test: PASS.
- 20-minute idle/screen-off: PASS.
- Kernel after flash: `6.12.23-android16-OP-WILD`.
- KernelSU-Next Manager: Working / Built-in GKI2 / `v3.2.0 (33169)`.
- Manager version: `v3.1.0 (33024)`.
- Hook mode: Inline / SuSFS.
- SUSFS initialized as `v2.1.0`.
- Shell root context after Magisk removal: `u:r:ksu:s0`.

## KSU Is Not Touch Proof

Old notes include KernelSU overlay ideas for replacing modules like `zte_tpd.ko`.

Rule:

- KSU overlay/bind mount does not prove the intended module code is active.
- Runtime proof needs Build-ID/hash comparison against the loaded module.
- KSU should improve evidence collection, not blur kernel/recovery/root test boundaries.

## What Helps Canoe Dock

Promote:

- validated package hash.
- validation summary.
- KSU-only root proof.
- rollback safety.

Do not promote:

- app hiding or bypass guidance.
- broad claims that KSU overlay proves a custom driver loaded.
- module replacement recipes without Build-ID proof.

## Source References

- `<repo-root>/docs/09-anykernel3-gki.md`
- `<repo-root>/docs/10-kernelsu-next-susfs.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/KSU_PATCHING.md`
- `<local-build-root>/devices/RedMagic-11-Pro/kernels/AK3_OP15_OOS16_android16-6.12.23_KSUN_33068_SuSFS_v2.0.0`
