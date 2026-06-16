# AnyKernel Releases

This folder indexes RM11 Pro / NX809J AnyKernel3 packages.

Current known package:

- [RM11 Pro Android 16 6.12.23 OP-WILD KernelSU-Next/SUSFS](rm11pro-android16-6.12.23-opwild-ksun-susfs/README.md)
- [RM11 Pro Android 16 6.12.23 Droidspace Goldbug guarded](rm11pro-android16-6.12.23-droidspace-goldbug-guarded/README.md)

The Droidspace Goldbug guarded package is committed as a public prebuilt. The
older OP-WILD KernelSU/SUSFS package remains documented by hashes/provenance.

Current local guarded package:

```text
<kernel-build-root>/AK3_RM11Pro_Android16_6.12.23_KSUN_SuSFS_v2.1.0.zip
sha256: 7cac8a90fd065fd2f31f8e1938ece8f5bea061cbd8213a03e44b86ba50ea1b4a
```

Do not use the older local raw `AnyKernel3_gki_6.12.23_Gold_bug.zip` as an
RM11 release candidate. Its `anykernel.sh` was observed with `do.devicecheck=0`,
empty `device.name*` fields, and automatic vbmeta behavior. Use the guarded
Droidspace package instead.
