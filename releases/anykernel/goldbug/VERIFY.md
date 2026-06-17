# Verify Droidspace Goldbug Guarded AnyKernel3

Local hash check:

```bash
sha256sum AK3-RM11-Goldbug.zip
```

Expected:

```text
c00f8f0ccc3b1b479e419634b15408d8dfbcd107ad4e3568f11c297661623056
```

Confirm the guarded installer is inside the zip:

```bash
unzip -p AK3-RM11-Goldbug.zip anykernel.sh | grep -E 'do.devicecheck=1|PATCH_VBMETA_FLAG=0|NX809J|6.12.23'
```

Confirm the payload Image hash:

```bash
rm -rf /tmp/rm11-ak3-check
mkdir -p /tmp/rm11-ak3-check
unzip -q AK3-RM11-Goldbug.zip Image anykernel.sh -d /tmp/rm11-ak3-check
sha256sum /tmp/rm11-ak3-check/Image /tmp/rm11-ak3-check/anykernel.sh
rm -rf /tmp/rm11-ak3-check
```

Expected:

```text
286c57152a5e1169b947d80850aea1eee8cc602f61c769b2059304783c8acd39  Image
f6d1c106b02eaeb22a365a06e79457bea345858547baf53bab104e0858396e15  anykernel.sh
```
