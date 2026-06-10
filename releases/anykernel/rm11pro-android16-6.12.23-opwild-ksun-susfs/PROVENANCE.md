# Provenance

Package:

```text
AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0_TEST.zip
```

Current local package path:

```text
/mnt/e/Android/RM-11-Pro/KERNELS/BUILDS/AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0.zip
```

Lineage:

- WildKernel OP-WILD OP15 Android 16 `6.12.23` KSU/SUSFS Image lineage.
- AnyKernel3 packaging.
- RM11 device and kernel-minor guardrails added in the validation workspace.
- Device validation performed on RM11 Pro / REDMAGIC 11 Pro / NX809J slot `_a`.

Guardrail audit:

- The current local package has `do.devicecheck=1`.
- The current local package checks `NX809J` / `NX809J-UN` / RM11 model strings.
- The current local package aborts unless runtime kernel minor is `6.12.23`.
- The current local package targets `boot` and leaves `patch_vbmeta_flag=0`.
- The older local `AnyKernel3_gki_6.12.23_Gold_bug.zip` is reference-only because it was observed with disabled device checks.
- Reproducible guardrail patch: `anykernel-rm11-guardrails.patch`.

Final ZIP SHA-256:

```text
7CAC8A90FD065FD2F31F8E1938ECE8F5BEA061CBD8213A03E44B86BA50EA1B4A
```

Known root transition:

- Earlier validation: Magisk shell root through `init_boot_a`.
- Final validation: KernelSU-only shell root, `context=u:r:ksu:s0`.

Known manager state:

- KernelSU-Next: Working / Built-in GKI2 / `v3.2.0 (33169)`.
- Manager: `v3.1.0 (33024)`.
- Hook mode: Inline / SuSFS.
- SUSFS: `v2.1.0`.
