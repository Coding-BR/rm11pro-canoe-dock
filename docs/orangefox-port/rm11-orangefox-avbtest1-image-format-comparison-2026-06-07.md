# RM11 OrangeFox AVBTEST1 Image Format Comparison - 2026-06-07

## Scope

This is the controlled OrangeFox RM11 AVB recovery signing rebuild follow-up.

No device-side test was performed.

No flash was performed.

No boot-pass claim is made.

Previous hardware result remains:

```text
build-pass / flash-pass-old / boot-fail-old / rollback-pass
```

New classification after this rebuild:

```text
build-pass / flash-pass-old / boot-fail-old / rollback-pass / avb-signed rebuild ready for cautious test
```

## Build Inputs

Device tree:

```text
<repo-root>/recovery/device/zte/sm88XX
```

Synced build tree copy:

```text
<orangefox-tree>/device/nubia/NX809J
```

Prebuild diff:

```text
/tmp/rm11-orangefox-avb-signing-fix-prebuild.diff
```

Copied output diff:

```text
C:\Users\Richtofen\Documents\Codex\2026-06-07\files-mentioned-by-the-user-anykernel3\outputs\rm11pro-orangefox-build-avbtest1\rm11-orangefox-avb-signing-fix-prebuild.diff
```

Prebuild diff SHA-256:

```text
d513ce31781be0228ace18d005e2becc108c6cebc84fc0510e5e64609dfbe8f1
```

## Config Delta

The RM11 device tree now sets recovery-specific AVB footer signing variables:

```make
BOARD_AVB_RECOVERY_KEY_PATH := device/nubia/NX809J/keys/avb-test/rm11_recovery_avb_testkey.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 0
```

The key is a generated validation key:

```text
keys/avb-test/rm11_recovery_avb_testkey.pem
```

It is not the stock/OEM recovery signing key.

The generated key passed:

```text
openssl rsa -in keys/avb-test/rm11_recovery_avb_testkey.pem -check -noout
RSA key ok
```

The public key SHA-1 emitted in the new AVB footer is:

```text
0edd1a852e4dc1cecabb28e9061506fc62cf36a5
```

That does not match the stock recovery AVB public key SHA-1:

```text
c25f7c19c9f1130b765425620028654fe8f591cf
```

## Metadata Adjustment

The failed image used synthetic metadata:

```text
OS version: 99.87.36
OS patch level: 2099-12
```

An attempt to use `PLATFORM_VERSION := 16` failed because this AP2A/fox_14.1 build base only lists these CTS platform releases:

```text
14
99.87.36
```

The unsupported `16` attempt failed with:

```text
Could not find version "16" in CTS platform release file:
cts/tests/tests/os/assets/platform_releases.txt
```

The successful AVBTEST1 build therefore uses the supported non-fake platform version:

```make
PLATFORM_VERSION := 14
PLATFORM_SECURITY_PATCH := 2025-12-01
```

This removes the fake `99.87.36` / `2099-12-31` metadata without changing the build base to Android 16 or changing SystemSDK behavior.

## Build Result

Build command:

```bash
cd "<orangefox-tree>"
source build/envsetup.sh
lunch orangefox_NX809J-ap2a-eng
mka -j8 adbd recoveryimage
```

Result:

```text
PASS
```

Build log:

```text
C:\Users\Richtofen\Documents\Codex\2026-06-07\files-mentioned-by-the-user-anykernel3\outputs\rm11pro-orangefox-build-avbtest1\rm11_orangefox_avbtest1_build.log
```

The build log reports:

```text
PLATFORM_VERSION=14
INTERNAL_MKBOOTIMG_VERSION_ARGS=--os_version 14 --os_patch_level 2025-12-01
#### build completed successfully (04:10 (mm:ss)) ####
```

Generated and copied artifacts:

```text
C:\Users\Richtofen\Documents\Codex\2026-06-07\files-mentioned-by-the-user-anykernel3\outputs\rm11pro-orangefox-build-avbtest1\OrangeFox-R12.0-Unofficial-NX809J-avbtest1.img
C:\Users\Richtofen\Documents\Codex\2026-06-07\files-mentioned-by-the-user-anykernel3\outputs\rm11pro-orangefox-build-avbtest1\OrangeFox-R12.0-Unofficial-NX809J-avbtest1.zip
```

SHA-256:

```text
eb186188e7c18e7ef5ec8623ad4b1620b7dae3f9618075629008ff0ec2d6bd37  OrangeFox-R12.0-Unofficial-NX809J-avbtest1.img
d8301aa2cd42a8caf708ea6ddc26f574f797ec2da66a1fd971e9aa32816ed4e5  OrangeFox-R12.0-Unofficial-NX809J-avbtest1.zip
15060785feebb52e6094275eb51082e27aa930bc64cacc3e990201ac22d81e90  rm11_orangefox_avbtest1_build.log
```

MD5:

```text
70333c0d696ca1d9f8b10f03262a60b3  OrangeFox-R12.0-Unofficial-NX809J-avbtest1.img
e0b42c9d0288502de7dd7f6f595cb3bb  OrangeFox-R12.0-Unofficial-NX809J-avbtest1.zip
```

Size:

```text
OrangeFox-R12.0-Unofficial-NX809J-avbtest1.img 104857600
OrangeFox-R12.0-Unofficial-NX809J-avbtest1.zip 74099422
```

## Forensic Workspace

Side-by-side comparison workspace:

```text
<local-build-root>/recovery-forensics/rm11-orangefox-avbtest1-2026-06-07
```

Images compared:

```text
stock_recovery_a.img
failed_orangefox.img
avbtest1_orangefox.img
```

## Size And Hash Comparison

| Image | Size | SHA-256 |
|-------|------|---------|
| Stock `recovery_a` | `104857600` | `694eba1214ff90f1da496c2108e98479167b15f3f7eb631deb64493402303394` |
| Failed OrangeFox | `104857600` | `ff2b9de6ee69e96d1aa41722bae39bd4960dd8f374c8d7ba72a61ba5ae25028d` |
| AVBTEST1 OrangeFox | `104857600` | `eb186188e7c18e7ef5ec8623ad4b1620b7dae3f9618075629008ff0ec2d6bd37` |

All three files are recovery partition sized.

## Header Comparison

| Field | Stock recovery | Failed OrangeFox | AVBTEST1 OrangeFox |
|-------|----------------|------------------|--------------------|
| Boot magic | `ANDROID!` | `ANDROID!` | `ANDROID!` |
| Header version | `4` | `4` | `4` |
| Kernel size | `0` | `0` | `0` |
| Ramdisk size | `20458673` | `59614837` | `58749693` |
| OS version | `None` | `99.87.36` | `14.0.0` |
| OS patch level | `None` | `2099-12` | `2025-12` |
| Cmdline | empty | empty | empty |
| Boot image signature size | `0` | `0` | `0` |

AVBTEST1 remains a header v4 ramdisk-only recovery image, matching the stock image structure at the kernel/DTB level.

## AVB Footer Comparison

| Field | Stock recovery | Failed OrangeFox | AVBTEST1 OrangeFox |
|-------|----------------|------------------|--------------------|
| AVB footer | present | present | present |
| Image size | `104857600` | `104857600` | `104857600` |
| Original image size | `20463616` | `59621376` | `58757120` |
| VBMeta size | `2304` | `832` | `2432` |
| Authentication block | `576` | `0` | `576` |
| Public key SHA-1 | `c25f7c19c9f1130b765425620028654fe8f591cf` | absent | `0edd1a852e4dc1cecabb28e9061506fc62cf36a5` |
| Algorithm | `SHA256_RSA4096` | `NONE` | `SHA256_RSA4096` |
| Rollback index | `1` | `0` | `1` |
| Rollback index location | `0` | `0` | `0` |
| Partition name | `recovery` | `recovery` | `recovery` |
| Boot OS prop | absent | `99.87.36` | `14` |
| Boot security patch prop | absent | `2099-12-31` | `2025-12-01` |

## Exact AVB Deltas Fixed

Fixed:

* `Algorithm: NONE` -> `Algorithm: SHA256_RSA4096`
* authentication block `0` -> `576`
* public key absent -> public key present
* rollback index `0` -> `1`
* fake boot OS prop `99.87.36` -> supported AP2A value `14`
* fake boot security patch `2099-12-31` -> stock-aligned patch value `2025-12-01`

Still unchanged or intentionally not solved:

* AVBTEST1 uses a generated validation key, not the stock/OEM key.
* AVBTEST1 public key SHA-1 does not match stock recovery public key SHA-1.
* Recovery fingerprint still differs from stock recovery fingerprint:
  * stock: `20260204.223312`
  * AVBTEST1: `20260320.095121`
* AVBTEST1 still has OrangeFox recovery userspace, not stock recovery userspace.
* No camera, touch, decryption, fastbootd, or recovery ADB behavior was tested in this step.
* No device-side boot or flash was performed.

## Interpretation

The hard forensic mismatch from the failed image is fixed at the image-format level.

The new AVBTEST1 image is now suitable for a cautious controlled recovery flash test if and only if the operator accepts the remaining key mismatch risk.

The key risk is simple: the image is structurally signed, but it is not signed with the stock recovery key. If the unlocked RM11 recovery boot chain accepts non-stock AVB keys for recovery, this is the correct next test. If the boot chain requires the stock recovery public key, AVBTEST1 may still route to fastboot.

## Do Not Overclaim

Do not call AVBTEST1 bootable.

Do not publish AVBTEST1.

Do not mark recovery stable.

Do not chase kernel, DTB, or recovery_dtbo before testing this AVB-signed rebuild, because stock and OrangeFox remain ramdisk-only header v4 recovery images.
