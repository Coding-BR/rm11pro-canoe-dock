# OrangeFox Port Notes

This folder tracks the RM10 Pro OrangeFox recovery port work that was adapted for the REDMAGIC 11 Pro / NX809J.

Source roles:

- `/home/richtofen/.android/repositories/rm11pro-canoe-dock/ports/orangefox-recovery/device_nubia_NX809J`: current local fork path for the RM10 Pro to RM11 Pro OrangeFox device-tree port.
- `/home/richtofen/.android/repositories/MainAssets/OrangeFox_sync`: small OrangeFox sync helper and fox_14.1 patch set copied into `scripts/orangefox-sync`.
- `/home/richtofen/.android/repositories/MainAssets/fox_14.1`: full OrangeFox/TWRP source tree. Generated `out/` artifacts were deleted during cleanup and must be rebuilt when needed. This is not copied into Git.
- `/home/richtofen/.android/repositories/MainAssets/recovery-forensics`: local raw recovery images, logs, headers, and AVB comparisons. Raw payloads stay local; summary docs live here.
- `ports/orangefox-recovery/`: curated dock snapshot of the RM11 OrangeFox device-tree source/config/docs from the current fork.

Current status:

```text
build-pass / recovery_a-dd-test-fail / rollback-pass / stockfstab-mininit-candidate-built / codingbr-sm88xx-nx809j-splash-adb-pass-ui-blocked / rollback-pass / d1-nodecrypt-ui-adb-pass / d1t-d1t2-touch-fail / d1t3-basic-ui-touch-navigation-pass / d2e-boot-adb-pass-crypto-disabled / d2f-crypto-enabled-animation-stall / d2g-preflash-marker-proof-pass-not-flashed
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
- A separate Coding-BR sm88XX-in-Fox build target builds locally with
  `TARGET_BOARD_PLATFORM=sm8850`, `PRODUCT_PLATFORM=canoe`, and
  `TARGET_CPU_VARIANT_RUNTIME=oryon`.
- The 2026-06-10 rooted-Android `dd` test of the Coding-BR sm88XX-in-Fox image to
  `recovery_a` booted past the RedMagic logo, showed OrangeFox splash, and brought
  up root recovery ADB.
- The Coding-BR sm88XX-in-Fox test did not prove full UI, touch, decrypt, MTP,
  flashing, USB OTG, or reboot UI behavior.
- Logs from the splash/ADB test point first at Android 16 decrypt/security runtime
  incompatibility under the Fox 14 userspace, not at DRM graphics as the primary
  blocker.
- Candidate D1 disabled the decrypt/runtime lane and reached full OrangeFox UI
  plus root recovery ADB. D1 was a UI-isolation pass, not a decrypt pass.
- Candidate D1T and D1T2 did not improve touch. Recovery still jumped between
  search/keyboard/screens and buttons did not register reliably.
- Candidate D1T3 added Coding-BR/TWRP's NX809J minuitwrp touch normalization on
  top of D1T2. On 2026-06-11 it booted to OrangeFox, exposed root recovery ADB,
  disabled screen timeout, and allowed basic navigation through Backup, Menu,
  and Wipe views. Treat this as a basic UI/touch navigation pass only.
- D1T3 still does not prove decrypt, MTP, fastbootd, partition operations,
  backups, wipes, installs, USB OTG, or reboot-menu behavior.
- D2E booted with recovery ADB, but crypto was disabled
  (`ro.orangefox.crypto_enabled=0`) and service-start probing did not solve
  decrypt.
- D2F enabled crypto and reached the OrangeFox animation with recovery ADB, but
  did not reach the menu. Logs pointed at decrypt/security service restart
  loops.
- D2G is a preflash-only candidate. Its frozen artifact is exactly
  `104857600` bytes with SHA-256
  `a806ffcc82eeec0ffd29d2c07f5f8e6c9a8669fce783ce3901e4f6711baa9664`.
  The built recovery root now proves the D2G marker and all manual
  `sys.rm11.d2g.*` triggers landed.

Safety rules:

- Do not publish OrangeFox as usable yet.
- Do not retest the original failed image or pre-stock-fstab AVBTEST1 image.
- Keep stock `recovery_a` rollback ready before any device-side recovery test.
- Test only one recovery slot first.
- Treat the stock-fstab/minimal-init build as the next candidate only after the expected rollback path is confirmed.
- Keep D1T3 in the no-decrypt lane until the Android 16 keymint/gatekeeper/qsee
  runtime issue is handled separately.
- Do not flash D2G until `scripts/recovery/verify-d2g-preflash.sh` passes
  against the frozen local artifact and the intended one-slot test plan is
  explicit.

Key files:

- `rm11-orangefox-build-pass-2026-06-07.md`: build command, output names, SHA256 values, and partition-size check.
- `rm11-orangefox-flash-pass-boot-fail-rollback-pass-2026-06-07.md`: device-side flash result and rollback result.
- `rm11-orangefox-image-format-forensics-2026-06-07.md`: stock versus failed OrangeFox boot image and AVB comparison.
- `rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md`: AVBTEST1 image comparison before device-side testing.
- `rm11-orangefox-stockfstab-mininit-test-candidate-2026-06-09.md`: latest local rebuild and one-slot test plan.
- `codingbr-sm88xx-twrp-decryption-compare-2026-06-10.md`: comparison against Coding-BR's sm88XX TWRP tree and staged decryption plan.
- `staged-codingbr-sm88xx-import-plan-2026-06-10.md`: same-generation NX809J/sm8850 re-evaluation with Candidate A/B/C patch diffs.
- `codingbr-sm88xx-fox14-nx809j-test-build-2026-06-10.md`: local Coding-BR sm88XX tree imported into Fox 14.1 as a dedicated NX809J-named build target; build artifacts, hashes, header, AVB footer, and caveats.
- `codingbr-sm88xx-fox14-boot-adb-log-analysis-2026-06-10.md`: log-backed diagnosis for the splash/ADB test and the Candidate D plan.
- `d1t-touch-input-isolation-build-2026-06-11.md`: D1T build and touch-range test plan.
- `d1t3-minuitwrp-touch-normalization-pass-2026-06-11.md`: D1T/D1T2 failure summary, D1T3 source patch, build metadata, and basic UI/touch pass result.
- `d2e-d2f-d2g-decrypt-candidates-2026-06-14.md`: D2E/D2F results and D2G preflash marker proof.
- `rm11-live-adb-baseline.md`: live Android 16 ADB baseline before recovery validation.
- `rm11-post-ksun-adb-sanity.md`: post-KernelSU Android state.
- `orangefox-sync-map.md`: local fox_14.1 and OrangeFox_sync map.
- `recovery-forensics-manifest.md`: raw forensics folder policy and artifact map.
