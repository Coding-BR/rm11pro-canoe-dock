# AnyKernel3 GKI

Known validated AnyKernel package:

```text
AK3-RM11-OPWILD.zip
```

Note:

```text
The validated OP-WILD package is documented by hash/provenance. The local
filename may differ.
```

Final ZIP SHA-256:

```text
7CAC8A90FD065FD2F31F8E1938ECE8F5BEA061CBD8213A03E44B86BA50EA1B4A
```

This is a validated test build, not a universal release. It is for RM11 Pro / NX809J Android 16 kernel `6.12.23` baseline only.

Package guardrails observed in `anykernel.sh`:

- device check enabled.
- `NX809J` / `NX809J-UN` / RM11 model strings.
- exact `6.12.23` kernel minor check.
- boot partition target.
- vbmeta patching disabled.

Reference-only local package:

```text
/mnt/e/Android/RM-11-Pro/KERNELS/BUILDS/AnyKernel3_gki_6.12.23_Gold_bug.zip
```

Do not use that older package as the RM11 release/test candidate; it was
observed with disabled device checks.

Before flashing:

- Confirm exact model is RM11 Pro / NX809J.
- Confirm Android 16 baseline.
- Confirm current kernel minor is `6.12.23`.
- Keep rollback images.
- Do not flash it to RM10, Astra, Pad 3 Pro, Z70U, Z80U, or any other device.

Known validation:

- Boot after flash: PASS.
- Reboot persistence: PASS.
- Hardware smoke test: PASS.
- 20-minute idle/screen-off: PASS.
- KSU-only shell root: PASS.
