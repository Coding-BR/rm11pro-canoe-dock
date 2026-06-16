# RM11 Pro Android 16 6.12.23 OP-WILD KernelSU-Next/SUSFS

Package:

```text
AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0_TEST.zip
```

Current local filename:

```text
<kernel-build-root>/AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0.zip
```

Classification:

```text
validated test build
```

Final ZIP SHA-256:

```text
7CAC8A90FD065FD2F31F8E1938ECE8F5BEA061CBD8213A03E44B86BA50EA1B4A
```

Observed package guardrails:

- `do.devicecheck=1`.
- `do.check_boot_version=1`.
- `device.name1=NX809J`.
- `device.name2=NX809J-UN`.
- target partition is `boot`.
- `patch_vbmeta_flag=0`.
- aborts unless runtime kernel minor is exactly `6.12.23`.

Target:

- RM11 Pro / REDMAGIC 11 Pro / NX809J.
- Android 16.
- Kernel minor `6.12.23`.
- Kernel after flash: `6.12.23-android16-OP-WILD`.

Validated:

- Boot after flash: PASS.
- Reboot persistence: PASS.
- Hardware smoke test: PASS.
- 20-minute idle/screen-off: PASS.
- KernelSU-Next Manager: Working / Built-in GKI2 / `v3.2.0 (33169)`.
- Hook mode: Inline / SuSFS.
- SUSFS initialized as `v2.1.0`.
- KSU-only shell root: PASS, `context=u:r:ksu:s0`.

Required before any wider label:

- Longer daily-use observation.
- Regression watch for camera, modem, charging, thermal, fan/Game Space, and sleep/wake.
- Rollback files preserved off-device.
- Additional normal reboot after daily use.

Do not flash this to RM10, Astra, Pad 3 Pro, Z70U, Z80U, or other devices.
