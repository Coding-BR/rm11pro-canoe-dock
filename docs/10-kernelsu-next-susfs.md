# KernelSU-Next / SUSFS

Validated state for the OP-WILD AnyKernel3 package:

- Kernel after flash: `6.12.23-android16-OP-WILD`.
- KernelSU-Next Manager: Working / Built-in GKI2 / `v3.2.0 (33169)`.
- Manager version: `v3.1.0 (33024)`.
- Hook mode: Inline / SuSFS.
- SUSFS initialized as `v2.1.0`.
- Build type: Main.
- Shell root context after Magisk removal/no longer active: `u:r:ksu:s0`.

Validation status:

- Initial boot after flash: PASS.
- Slot safety: PASS.
- Android boot completion: PASS.
- OP-WILD kernel replacement: PASS.
- Reboot persistence: PASS.
- Hardware smoke test: PASS.
- 20-minute idle/screen-off: PASS.

Do not describe this as universal. Do not describe it as hiding root or bypassing apps. This repo only documents device validation and rollback safety.
