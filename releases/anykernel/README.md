# AnyKernel Releases

This folder indexes RM11 Pro / NX809J AnyKernel3 packages.

Current known package:

- [RM11 Pro Android 16 6.12.23 OP-WILD KernelSU-Next/SUSFS](rm11pro-android16-6.12.23-opwild-ksun-susfs/README.md)

No release ZIP is committed here. Use hashes, provenance, and expected paths until a maintainer explicitly adds artifacts through a release workflow.

Current local guarded package:

```text
/mnt/e/Android/RM-11-Pro/KERNELS/BUILDS/AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0.zip
sha256: 7cac8a90fd065fd2f31f8e1938ece8f5bea061cbd8213a03e44b86ba50ea1b4a
```

Do not use the older local `AnyKernel3_gki_6.12.23_Gold_bug.zip` as an RM11
release candidate. Its `anykernel.sh` was observed with `do.devicecheck=0` and
empty `device.name*` fields.
