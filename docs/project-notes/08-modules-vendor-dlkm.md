# Modules And vendor_dlkm

## Status

Module work is high value but risky. Treat it as a controlled test lane, not general flashing guidance.

Important modules/surfaces from notes:

- `zte_tpd.ko`
- `msm_kgsl.ko`
- `msm-mmrm.ko`
- `synx_driver.ko`
- `smcinvoke_dlkm.ko`
- `qseecom_dlkm.ko`
- `qcom_scmi_vendor.ko`
- `qcom_scmi_client.ko`
- `clk-scmi.ko`
- `spmi_pmic_arb.ko`
- display stack: `msm_drm.ko`
- audio stack modules.
- Bluetooth modules.

## Core Rule

Module presence is not module provenance.

`lsmod`, `/proc/modules`, or `/sys/module/zte_tpd` can prove something is loaded, but not necessarily that the rebuilt/custom file is the one running.

Runtime proof should include:

- `.ko` file SHA256.
- Build-ID of official module.
- Build-ID of rebuilt module.
- loaded module Build-ID from `/sys/module/<module>/notes/.note.gnu.build-id` when available.
- `/proc/modules` memory size.
- exact overlay or partition path used.

## Deployment Risk Ranking

Lowest risk:

- Built-in driver in RAM-booted image using `fastboot boot`, when the phone can return to stock on reboot.

Medium risk:

- Physical `vendor_dlkm` flash with stock rollback image ready.

High risk:

- Runtime hot reload with `rmmod` / `insmod`.

Avoid hot reload for critical paths:

- `zte_tpd`.
- charger/power policy.
- display/panel-linked modules.

## KernelSU Overlay Notes

KSU overlay can be useful for controlled tests, but it may be too late for early boot critical drivers.

Use it only when:

- root is already present.
- rollback/removal command is known.
- loaded module provenance is verified after boot.
- the test is not being mixed with kernel RAM-boot or recovery validation.

## Touchscreen Specific Notes

Useful touch baseline names:

- `synaptics_tcm_touch`
- `zte_tpd.ko`
- `/proc/touchscreen`
- `/proc/bus/input/devices`
- `getevent -lp`

Patch quarry preserved:

- `WORK_CPU_UNBOUND` / suspend-watchdog material.
- typed input-device patch.
- dynamic platform-device allocation idea.
- probe/remove/shutdown guards.
- KCFI/module ABI comparison.
- vendor_dlkm/module load-order parity.

## What Helps Canoe Dock

Promote:

- module test template.
- module provenance rule.
- known validated AnyKernel/KSU package, if treated as release artifact.
- warnings around hot reload and critical drivers.

Do not promote:

- giant `elf-analysis/` dumps.
- raw `.ko` files unless intentionally releasing modules.
- "stable" claims without same-run runtime proof.

## Source References

- `/mnt/e/Android/RM-11-Pro/staging-notes/MODULES.md`
- `<local-build-root>/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.tar.gz`
- `<repo-root>/docs/15-modules-and-tools.md`
- Former local `rm11-recovery-next-from-myfork-main` touchscreen/module notes, reviewed before cleanup and summarized here.
- Re-clone `https://github.com/Coding-BR/android_kernel_nubia_sm8850_qwjujube` when module source work resumes.
