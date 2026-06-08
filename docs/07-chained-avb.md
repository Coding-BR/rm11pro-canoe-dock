# Chained AVB

RM11 / RM10 style boot chains use chained AVB. Do not disable only one vbmeta layer and assume the rest of the chain will remain coherent.

Risky pattern:

```powershell
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
```

That can cause boot loops, dumper mode, failed verification, or broken boot-chain consistency when `vbmeta`, `vbmeta_system`, and dynamic partitions no longer agree.

Known community pattern from the XDA source guide:

```powershell
fastboot --disable-verity flash vbmeta_a vbmeta.img
fastboot --disable-verity flash vbmeta_b vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system_a vbmeta_system.img
fastboot --disable-verity --disable-verification flash vbmeta_system_b vbmeta_system.img
```

Only use vbmeta images from your exact firmware or a known-compatible ROM package. Do not mix vbmeta files across firmware versions.
