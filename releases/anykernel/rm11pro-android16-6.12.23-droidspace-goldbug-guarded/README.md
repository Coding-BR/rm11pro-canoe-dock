# RM11 Pro Android 16 6.12.23 Droidspace Goldbug Guarded

Package:

```text
AK3_RM11Pro_Android16_6.12.23_Droidspace-Goldbug_Guarded_2026-06-16.zip
```

Classification:

```text
Droidspace kernel guarded test package
```

This package is the public RM11 Pro / NX809J AnyKernel3 wrapper for the
Gold_bug Droidspace kernel payload. It exists because the raw upstream
`AnyKernel3_gki_6.12.23_Gold_bug.zip` had weak RM11 safety guardrails.

Final ZIP SHA-256:

```text
c00f8f0ccc3b1b479e419634b15408d8dfbcd107ad4e3568f11c297661623056
```

Payload and guardrail hashes:

```text
286c57152a5e1169b947d80850aea1eee8cc602f61c769b2059304783c8acd39  Image from Gold_bug package
f6d1c106b02eaeb22a365a06e79457bea345858547baf53bab104e0858396e15  guarded anykernel.sh
faf6dae488ab127e7d7ead183d68cb28592b537f8664b21f7017f825097aefb0  source AnyKernel3_gki_6.12.23_Gold_bug.zip
```

Guardrails added:

- `do.devicecheck=1`.
- `do.check_boot_version=1`.
- RM11/NX809J device identity checks.
- Runtime kernel minor must be `6.12.23`.
- Target partition is `boot`.
- Slot handling is `auto`.
- `PATCH_VBMETA_FLAG=0`.
- Raw upstream helper module install side paths are not carried over.

Target:

- RM11 Pro / REDMAGIC 11 Pro / NX809J.
- Android 16.
- Kernel minor `6.12.23`.
- Droidspace/Linux-container experiments.

Do not treat this as a generic daily-driver kernel guarantee. Keep a stock boot
rollback image before testing.
