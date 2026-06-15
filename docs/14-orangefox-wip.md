# OrangeFox WIP

Current OrangeFox result:

```text
build-pass / d1t3-basic-ui-touch-navigation-pass / d2e-boot-adb-pass-crypto-disabled / d2f-crypto-enabled-animation-stall / d2g-preflash-marker-proof-pass-not-flashed
```

Known facts:

- `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img` failed with `Bad Buffer Size`.
- The image is a recovery partition image, not a direct `fastboot boot` ramboot image.
- The 2026-06-09 `recovery_a` dd test reached the RedMagic logo and did not reach recovery UI or recovery ADB.
- Stock `recovery_a` rollback passed after Android boot was recovered.
- Android boot was restored.
- D1T3 reached basic OrangeFox UI/touch navigation with recovery ADB in the
  no-decrypt lane.
- D2E booted with recovery ADB but reported `ro.orangefox.crypto_enabled=0`.
- D2F enabled crypto, reached OrangeFox animation, exposed recovery ADB, and
  stalled before menu with decrypt/security service restart loops.
- D2G is not flashed. Current work is preflash proof only.

Forensic finding:

- Stock and OrangeFox are both Android boot image header v4 ramdisk-only recovery images.
- The first hard mismatch was AVB metadata.
- Stock recovery has signed `SHA256_RSA4096` recovery footer with rollback index `1`.
- Failed OrangeFox had `Algorithm: NONE`, rollback index `0`, and no auth block.
- AVBTEST1 uses a generated validation key, not the OEM key.
- The 2026-06-09 stock-fstab/minimal-init rebuild keeps the recovery fstab and qcom init hook closer to stock standalone recovery.

Current local test candidate:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2g-crypto-enabled-manual-service-overlay/OrangeFox-R12.0-Unofficial-NX809J-d2g-crypto-enabled-manual-service-overlay.img
sha256: a806ffcc82eeec0ffd29d2c07f5f8e6c9a8669fce783ce3901e4f6711baa9664
size: 104857600 bytes
```

D2G preflash proof:

- AVB fingerprint contains `orangefox_NX809J_codingbr_d2g`.
- Built recovery root contains
  `ro.rm11.decrypt_candidate_d2g=d2g-crypto-enabled-manual-service-overlay`
  in `default.prop` and `prop.default`.
- Built recovery root contains every `sys.rm11.d2g.*` manual trigger.
- `ro.orangefox.crypto_enabled` is a runtime property from the
  `TW_INCLUDE_CRYPTO` compile lane, not a static default property.

Current warning:

- Do not publish OrangeFox as usable.
- Do not retest the original failed image or the pre-stock-fstab AVBTEST1 image.
- Keep stock `recovery_a` rollback available before any recovery test.
- Test only one recovery slot first.
- Keep recovery WIP until UI, touch, ADB, mount/decryption behavior, and reboot-to-system pass.
- Run `scripts/recovery/verify-d2g-preflash.sh` before considering any D2G
  device-side test.

Detailed evidence:

- [OrangeFox port notes](orangefox-port/README.md)
- [Recovery image forensics](orangefox-port/rm11-orangefox-image-format-forensics-2026-06-07.md)
- [AVBTEST1 comparison](orangefox-port/rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md)
- [2026-06-09 stock-fstab/minimal-init candidate](orangefox-port/rm11-orangefox-stockfstab-mininit-test-candidate-2026-06-09.md)
- [D2E/D2F/D2G decrypt candidates](orangefox-port/d2e-d2f-d2g-decrypt-candidates-2026-06-14.md)
