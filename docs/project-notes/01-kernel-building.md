# Kernel Building And Patching

## Status

Kernel work is useful but still experimental. The clean public dock should describe it as research, not an end-user release path.

Strongest validated kernel-adjacent result in the scanned notes:

- RAM boot reached Android.
- Runtime marker observed: `6.12.23-android16-OP-WILD-rm11-fresh-upstream-a`.
- `sys.boot_completed=1`.
- Slot `_a`.
- 5, 10, and 20 minute idle/screen-off checks passed.

Do not overclaim this:

- It does not prove every image named `dev_reverse_perfect.img` is identical.
- It does not prove rebuilt/custom `zte_tpd` was the active touch driver.
- It does not resolve the blue dump on wake issue.

## Main Blockers

### Blue Dump On Wake

Current best lead from the staged notes is display/panel resume or DTB/bootconfig packaging. Touch/IRQ remains secondary unless logs name `zte_tpd`, `syna`, touch IRQ, or `tpd_resume`.

Evidence to collect before more kernel edits:

- Image SHA256.
- Exact `fastboot boot` command.
- Slot.
- Runtime marker.
- `/proc/cmdline`.
- `dmesg` before suspend.
- post-wake logs if reachable.
- pstore/ramoops/ramdump after failure.
- display/panel/DSI/backlight/wake IRQ traces.
- `/proc/modules` and Build-ID/provenance for relevant modules.

### Build 8 RedMagic Logo Hang

Trusted project lead: custom GKI Build #8 boots past early init but hangs at RedMagic logo.

Likely chain preserved from the diagnostic notes:

```text
SCMI arm-scmi.1.auto timeout
-> cpuss_telemetry_probe cannot find shared memory
-> ADSP/CDSP remoteproc unavailable
-> smcinvoke/qseecom/keymint absent
-> vold cannot decrypt /data
-> /data does not mount
-> Android hangs at RedMagic logo
```

Important distinction:

- `qcom_scm_cfg_pddr_protected_region: resp 4 ret -22` and SCM mem protection `resp 7` also appear on stock and are probably non-fatal.
- The real divergence is SCMI timeout plus missing keymint/vold/decryption path.

## Build System Facts

Useful files from old notes:

- `super_build.sh`: kernel and techpack build script.
- `repack_perfect_sign.sh`: Image + dtb image packaging.
- `repack_no_dtb.sh`: no-DTB packaging experiment.
- `mkbootimg_v4.py`: boot image v4 writer.
- `codex_fresh_upstream_build.log`: build log with `zte_get_boot_mode` unresolved for `zte_tpd.ko`.

Known image-shape correction:

- Local `repack_perfect_sign.sh` uses `Image + dtb.img`.
- Local pack path passes `/dev/null` as ramdisk.
- That means docs telling us to inspect a ramdisk inside that specific locally packed image are stale or refer to another image.
- Track `boot`, `init_boot`, `vendor_boot`, `dtbo`, embedded FDT, and bootconfig separately.

## Missing Source / GPL Context

The kernel source release appears incomplete for a reproducible RM11 build. Preserved high-value gaps:

- Missing platform defconfig/fragment: `canoe.fragment` or equivalent.
- Missing WLAN host driver source.
- Missing or incomplete QCOM/ZTE headers.
- Missing proprietary ZTE module sources.
- Audio/display/camera/video techpack build gaps that were patched locally.

Resolved or partly reconstructed items in notes:

- MMRM.
- Synx and HW fence.
- `linux/mem-buf.h`.
- `linux/msm_ion.h`.
- `linux/msm_dma_iommu_mapping.h`.
- `linux/hdcp_qseecom.h`.
- `linux/qcom-iommu-util.h`.
- `soc/qcom/minidump.h`.
- `qcom_rproc.h` / `rproc_set_state`.
- audio-kernel Kbuild/API fixes.
- camera/display/Bluetooth/ZTE module progress.

## What Helps Canoe Dock

Promote to `rm11pro-canoe-dock` only as documentation/evidence:

- Known-good RAM boot/idle evidence with hashes.
- Build #8 SCMI/FBE diagnosis as a research track.
- Blue-dump-on-wake triage requirements.
- GPL/source-completeness summary.
- Warnings that kernel fork is developer research.

Do not promote:

- Giant reverse-engineering dumps.
- Unverified "stable" claims.
- Any boot image without SHA256 and source partition breakdown.

## Source References

- `/mnt/e/Android/RM-11-Pro/staging-notes/README_X1_FRESH_START.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/KERNEL_BUILDING_PATCHING.md`
- `/mnt/e/Android/RM-11-Pro/staging-notes/ROM_MAKING_USEFUL_KEEPERS.md`
- `<local-build-root>/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.tar.gz`
- `<repo-root>/docs/09-anykernel3-gki.md`
- `<repo-root>/docs/10-kernelsu-next-susfs.md`
