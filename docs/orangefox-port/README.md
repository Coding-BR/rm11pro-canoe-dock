# OrangeFox Port Notes

This folder tracks the RM10 Pro OrangeFox recovery port work that was adapted for the REDMAGIC 11 Pro / NX809J.

Source roles:

- `/home/richtofen/android/repositories/rm11pro-canoe-dock/ports/orangefox-recovery/device_nubia_NX809J`: current local fork path for the RM10 Pro to RM11 Pro OrangeFox device-tree port.
- `/home/richtofen/android/repositories/MainAssets/OrangeFox_sync`: small OrangeFox sync helper and fox_14.1 patch set copied into `scripts/orangefox-sync`.
- `/home/richtofen/android/repositories/MainAssets/fox_14.1`: full OrangeFox/TWRP source tree. Generated `out/` artifacts were deleted during cleanup and must be rebuilt when needed. This is not copied into Git.
- `/home/richtofen/android/repositories/MainAssets/recovery-forensics`: local raw recovery images, logs, headers, and AVB comparisons. Raw payloads stay local; summary docs live here.
- `ports/orangefox-recovery/`: curated dock snapshot of the RM11 OrangeFox device-tree source/config/docs from the current fork.

Current status:

```text
build-pass / recovery_a-dd-test-fail / rollback-pass / stockfstab-mininit-candidate-built
```

High-confidence facts:

- OrangeFox for NX809J built successfully from the fox_14.1 tree.
- `fastboot boot` failed with `Bad Buffer Size`.
- Standard `fastboot boot` is not a useful recovery test path for this layout.
- The 2026-06-09 rooted-Android `dd` test to `recovery_a` reached the RedMagic logo and did not reach OrangeFox UI/ADB.
- Stock `recovery_a` rollback restored Android boot.
- Stock and OrangeFox images are both Android boot image header v4 ramdisk-only recovery images.
- The failed OrangeFox image differed from stock in AVB metadata: stock used `SHA256_RSA4096` and rollback index `1`; failed OrangeFox used algorithm `NONE` and rollback index `0`.
- AVBTEST1 rebuild restores `SHA256_RSA4096` and rollback index `1` with a generated validation key, not the OEM key.
- The current local candidate additionally replaces the vendor_boot-derived recovery fstab and aggressive qcom recovery init with stock-derived/minimal versions.

Safety rules:

- Do not publish OrangeFox as usable yet.
- Do not retest the original failed image or pre-stock-fstab AVBTEST1 image.
- Keep stock `recovery_a` rollback ready before any device-side recovery test.
- Test only one recovery slot first.
- Treat the stock-fstab/minimal-init build as the next candidate only after the expected rollback path is confirmed.

Key files:

- `rm11-orangefox-build-pass-2026-06-07.md`: build command, output names, SHA256 values, and partition-size check.
- `rm11-orangefox-flash-pass-boot-fail-rollback-pass-2026-06-07.md`: device-side flash result and rollback result.
- `rm11-orangefox-image-format-forensics-2026-06-07.md`: stock versus failed OrangeFox boot image and AVB comparison.
- `rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md`: AVBTEST1 image comparison before device-side testing.
- `rm11-orangefox-stockfstab-mininit-test-candidate-2026-06-09.md`: latest local rebuild and one-slot test plan.
- `rm11-live-adb-baseline.md`: live Android 16 ADB baseline before recovery validation.
- `rm11-post-ksun-adb-sanity.md`: post-KernelSU Android state.
- `orangefox-sync-map.md`: local fox_14.1 and OrangeFox_sync map.
- `recovery-forensics-manifest.md`: raw forensics folder policy and artifact map.
