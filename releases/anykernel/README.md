# AnyKernel Releases

This folder indexes RM11 Pro / NX809J AnyKernel3 packages.

Current DroidSpaces runtime lane:

- [RM11 Pro Android 16 6.12.23 OP-WILD KernelSU-Next/SUSFS](opwild/README.md)

Experimental package:

- [RM11 Pro Android 16 6.12.23 Droidspace Goldbug guarded](goldbug/README.md)

OP-WILD is the active tested DroidSpaces direction right now. Goldbug is kept as
a guarded experimental package, not the default recommendation.

OP-WILD package hash, documented but not committed here:

```text
sha256: 7cac8a90fd065fd2f31f8e1938ece8f5bea061cbd8213a03e44b86ba50ea1b4a
```

Do not use the older local raw `AnyKernel3_gki_6.12.23_Gold_bug.zip` as an
RM11 release candidate. Its `anykernel.sh` was observed with `do.devicecheck=0`,
empty `device.name*` fields, and automatic vbmeta behavior. Use the guarded
Droidspace package instead.
