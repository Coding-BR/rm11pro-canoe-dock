# OrangeFox WIP

Current OrangeFox result:

```text
build-pass / recovery_a-dd-test-fail / rollback-pass / stockfstab-mininit-candidate-built
```

Known facts:

- `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img` failed with `Bad Buffer Size`.
- The image is a recovery partition image, not a direct `fastboot boot` ramboot image.
- The 2026-06-09 `recovery_a` dd test reached the RedMagic logo and did not reach recovery UI or recovery ADB.
- Stock `recovery_a` rollback passed after Android boot was recovered.
- Android boot was restored.

Forensic finding:

- Stock and OrangeFox are both Android boot image header v4 ramdisk-only recovery images.
- The first hard mismatch was AVB metadata.
- Stock recovery has signed `SHA256_RSA4096` recovery footer with rollback index `1`.
- Failed OrangeFox had `Algorithm: NONE`, rollback index `0`, and no auth block.
- AVBTEST1 uses a generated validation key, not the OEM key.
- The 2026-06-09 stock-fstab/minimal-init rebuild keeps the recovery fstab and qcom init hook closer to stock standalone recovery.

Current local test candidate:

```text
/home/richtofen/android/repositories/MainAssets/fox_14.1/out/target/product/NX809J/OrangeFox-R12.0-Unofficial-NX809J.img
sha256: 9a3d822bbe8201321934a3e746b6c2efc6ef4c037939a858e94487fd866e2d4d
size: 104857600 bytes
```

Current warning:

- Do not publish OrangeFox as usable.
- Do not retest the original failed image or the pre-stock-fstab AVBTEST1 image.
- Keep stock `recovery_a` rollback available before any recovery test.
- Test only one recovery slot first.
- Keep recovery WIP until UI, touch, ADB, mount/decryption behavior, and reboot-to-system pass.

Detailed evidence:

- [OrangeFox port notes](orangefox-port/README.md)
- [Recovery image forensics](orangefox-port/rm11-orangefox-image-format-forensics-2026-06-07.md)
- [AVBTEST1 comparison](orangefox-port/rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md)
- [2026-06-09 stock-fstab/minimal-init candidate](orangefox-port/rm11-orangefox-stockfstab-mininit-test-candidate-2026-06-09.md)
