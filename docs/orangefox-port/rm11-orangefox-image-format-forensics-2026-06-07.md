# RM11 OrangeFox Image Format Forensics - 2026-06-07

## Scope

Compare the stock RM11 Pro `recovery_a` image against the first OrangeFox NX809J build after the failed recovery boot.

Device-side result before this forensic pass:

* `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img`: FAIL, `Bad Buffer Size`
* `fastboot flash recovery_a OrangeFox-R12.0-Unofficial-NX809J.img`: PASS
* Boot to recovery: FAIL, routed to fastboot
* Stock `recovery_a` rollback: PASS
* Android boot after rollback: PASS

No rebuild, retest, or publishing was done during this pass.

## Inputs

| Image | Source | Forensic copy |
|-------|--------|---------------|
| Stock recovery | `E:\Android\RM-11-Pro\RECOVERY\BACKUP-BEFORE-ORANGEFOX-2026-06-07\recovery_a_stock_before_orangefox.img` | `/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-2026-06-07/stock_recovery_a.img` |
| OrangeFox recovery | `C:\Users\Richtofen\Documents\Codex\2026-06-07\files-mentioned-by-the-user-anykernel3\outputs\rm11pro-orangefox-build\OrangeFox-R12.0-Unofficial-NX809J.img` | `/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-2026-06-07/orangefox_recovery.img` |

Forensic workspace:

```text
/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-2026-06-07/
```

## Basic File Comparison

| Field | Stock recovery | OrangeFox recovery |
|-------|----------------|--------------------|
| Size | `104857600` bytes | `104857600` bytes |
| SHA-256 | `694eba1214ff90f1da496c2108e98479167b15f3f7eb631deb64493402303394` | `ff2b9de6ee69e96d1aa41722bae39bd4960dd8f374c8d7ba72a61ba5ae25028d` |
| `file` | `Android bootimg` | `Android bootimg` |

Both files are exactly recovery partition sized.

## Header Layout

The first 4096 bytes were dumped with `xxd -l 4096` into:

```text
headers/stock_header_4096.xxd
headers/orangefox_header_4096.xxd
```

Both start with Android boot image magic:

```text
ANDROID!
```

Header tool comparison:

| Field | Stock recovery | OrangeFox recovery |
|-------|----------------|--------------------|
| Boot image header version | `4` | `4` |
| Page size | `4096` | `4096` |
| Kernel size | `0` | `0` |
| Ramdisk size | `20458673` | `59614837` |
| Ramdisk format | `lz4_legacy` | `lz4_legacy` |
| OS version | `None` | `99.87.36` |
| OS patch level | `None` | `2099-12` |
| Command line | empty | empty |
| Boot image signature size | `0` | `0` |

`magiskboot` independently agrees:

```text
Stock:
HEADER_VER      [4]
KERNEL_SZ       [0]
RAMDISK_SZ      [20458673]
PAGESIZE        [4096]
CMDLINE         []
RAMDISK_FMT     [lz4_legacy]
VBMETA

OrangeFox:
HEADER_VER      [4]
KERNEL_SZ       [0]
RAMDISK_SZ      [59614837]
OS_VERSION      [99.87.36]
OS_PATCH_LEVEL  [2099-12]
PAGESIZE        [4096]
CMDLINE         []
RAMDISK_FMT     [lz4_legacy]
VBMETA
```

## Boot Image Tool Coverage

| Tool | Stock result | OrangeFox result | Notes |
|------|--------------|------------------|-------|
| `unpack_bootimg.py` | Parsed successfully | Parsed successfully | Authoritative for header version and mkbootimg args |
| `magiskboot unpack` | Parsed successfully | Parsed successfully | Confirms header v4, no kernel, LZ4 ramdisk, VBMETA |
| `unpackbootimg` | Timed out, `exit=124` | Timed out, `exit=124` | Not useful for this image pair |
| `bootimg.py` | Not available | Not available | `bootimg.py not found in PATH` |
| `avbtool info_image` | Parsed successfully | Parsed successfully | Key evidence for footer mismatch |

`unpack_bootimg.py --format mkbootimg` reconstruct arguments:

```text
Stock:
--header_version 4 --kernel .../kernel --ramdisk .../ramdisk --cmdline ''

OrangeFox:
--header_version 4 --os_version 99.87.36 --os_patch_level 2099-12 --kernel .../kernel --ramdisk .../ramdisk --cmdline ''
```

## AVB Footer Comparison

The last 4096 bytes were dumped into:

```text
headers/stock_tail_4096.xxd
headers/orangefox_tail_4096.xxd
```

Both images contain `AVBf` at the end of the 100 MiB partition image:

```text
0x063fffc0: AVBf
```

So OrangeFox did not omit the AVB footer entirely. The problem is that the footer metadata does not match stock verification behavior.

| Field | Stock recovery | OrangeFox recovery |
|-------|----------------|--------------------|
| Footer version | `1.0` | `1.0` |
| Full image size | `104857600` | `104857600` |
| Original image size | `20463616` | `59621376` |
| VBMeta offset | `20463616` | `59621376` |
| VBMeta size | `2304` | `832` |
| Header block | `256` | `256` |
| Authentication block | `576` | `0` |
| Auxiliary block | `1472` | `576` |
| Public key SHA-1 | `c25f7c19c9f1130b765425620028654fe8f591cf` | absent |
| Algorithm | `SHA256_RSA4096` | `NONE` |
| Rollback index | `1` | `0` |
| Rollback index location | `0` | `0` |
| Hash descriptor partition | `recovery` | `recovery` |
| Hash algorithm | `sha256` | `sha256` |

Stock AVB property:

```text
com.android.build.recovery.fingerprint =
REDMAGIC/NX809J-UN/NX809J:16/BQ2A.250705.001-BP2A.250605.031.A3/20260204.223312:user/release-keys
```

OrangeFox AVB properties:

```text
com.android.build.recovery.fingerprint =
REDMAGIC/NX809J-UN/NX809J:16/BQ2A.250705.001-BP2A.250605.031.A3/20260320.095121:user/release-keys

com.android.build.boot.os_version = 99.87.36
com.android.build.boot.security_patch = 2099-12-31
```

## Ramdisk Extraction

Both ramdisks extracted as valid ASCII cpio archives:

```text
magiskboot_stock/ramdisk.cpio: ASCII cpio archive (SVR4 with no CRC)
magiskboot_orangefox/ramdisk.cpio: ASCII cpio archive (SVR4 with no CRC)
```

Component and file-list comparison:

| Field | Stock recovery | OrangeFox recovery |
|-------|----------------|--------------------|
| Compressed ramdisk | `20458673` bytes | `59614837` bytes |
| Extracted cpio | `41586532` bytes | `164473344` bytes |
| Relative file entries | `484` | `4274` |
| Stock-only relative entries | `124` | n/a |
| OrangeFox-only relative entries | n/a | `3914` |
| Kernel component | `0` bytes | `0` bytes |

There is no kernel identity to compare inside these recovery images because both have `kernel_size=0`. The boot kernel and DTB are expected to come from the normal boot/vendor_boot boot chain, not from `recovery_a`.

Selected common file size comparison:

| File | Stock | OrangeFox |
|------|-------|-----------|
| `default.prop` | symlink, `12` bytes | symlink, `12` bytes |
| `prop.default` | `54371` bytes | `10211` bytes |
| `sepolicy` | `1602782` bytes | `688418` bytes |
| `system/etc/recovery.fstab` | `3755` bytes | `8264` bytes |
| `system/etc/ueventd.rc` | `3330` bytes | `3340` bytes |
| `init.recovery.qcom.rc` | `2175` bytes | `3714` bytes |

## Ramdisk Content Differences

Important stock recovery services present in the stock ramdisk:

```text
system/bin/hw/android.hardware.boot-service.qti.recovery
system/bin/hw/android.hardware.fastboot-service.example_recovery
system/bin/hw/android.hardware.health-service.qti_recovery
system/etc/init/android.hardware.boot-service.qti.recovery.rc
system/etc/init/android.hardware.fastboot-service.example_recovery.rc
system/etc/init/android.hardware.health-service.qti_recovery.rc
system/etc/init/servicemanager.recovery.rc
system/etc/vintf/manifest/android.hardware.fastboot-service.example.xml
system/etc/vintf/manifest/android.hardware.health-service.qti.xml
system/etc/vintf/manifest/boot-service.qti.xml
```

Init rc inventory:

```text
Stock:
init.recovery.qcom.rc

OrangeFox:
init.recovery.hlthchrg.rc
init.recovery.ldconfig.rc
init.recovery.logd.rc
init.recovery.qcom.rc
init.recovery.service.rc
init.recovery.usb.rc
init.recovery.wifi.rc
system/etc/init/hw/init.rc
```

OrangeFox has related but not identical services, mostly through generic system services plus vendor/odm prebuilts:

```text
system/bin/android.hardware.boot@1.0-service
system/bin/android.hardware.boot@1.1-service
system/bin/android.hardware.boot@1.2-service
system/bin/android.hardware.health@2.1-service
system/bin/fastbootd
vendor/etc/init/android.hardware.boot-service.qti.rc
vendor/etc/init/android.hardware.gatekeeper-service-qti.rc
vendor/etc/init/android.hardware.health-service.qti.rc
vendor/etc/init/android.hardware.security.keymint-service-qti.rc
vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc
vendor/etc/init/qseecomd.rc
vendor/etc/vintf/manifest/boot-service.qti.xml
```

Vendor-specific RM11/Nubia/ZTE path check:

```text
Stock path hits for nubia/zte/NX809J/redmagic/canoe/alor:
none

OrangeFox path hits:
vendor/etc/init/touchscreen_zte.rc
```

Text-content hits for device/vendor strings exist in both ramdisks, mostly in property/context files. The only direct ZTE-named init path found in the OrangeFox ramdisk is `vendor/etc/init/touchscreen_zte.rc`.

Stock `init.recovery.qcom.rc` is minimal: backlight, configfs USB, USB controller handoff, and `/dev/block/bootdevice` symlink creation. OrangeFox `init.recovery.qcom.rc` is broader: it stops keystore/keymint, starts vendor boot and crypto prep, mounts firmware, starts health services, starts haptic/touch/security services, and toggles fan/LED paths.

Stock `recovery.fstab` is narrow and Android 16 stock-like:

* logical `system`, `system_ext`, `product` use `avb=vbmeta_system`
* logical `vendor`, `odm` use `avb`
* `/metadata` is F2FS with `wrappedkey`
* `/data` is F2FS with `fileencryption=ice`, `wrappedkey`, and metadata keydirectory

OrangeFox `recovery.fstab` is broader:

* includes EROFS and ext4 fallback rows
* includes physical `/boot`, `/init_boot`, `/vendor_boot`, `/dtbo`, and `/recovery` entries
* uses `avb=vbmeta` on physical boot partitions
* adds firmware, persist, VM, SD card, and USB OTG rows
* uses newer inline crypto strings that are not identical to the stock recovery fstab

Property baseline mismatch:

| Property | Stock | OrangeFox |
|----------|-------|-----------|
| `ro.build.version.sdk` | `36` | `34` |
| `ro.build.version.release` | `16` | `99.87.36` |
| `ro.build.version.security_patch` | `2025-12-01` | `2099-12-31` |
| `ro.build.tags` | `release-keys` | `test-keys` |
| `ro.product.system.name` | `NX809J-UN` | `fox_NX809J` |
| `ro.product.system.model` | `NX809J` | `REDMAGIC 11 Pro` |
| `ro.vendor.build.security_patch` | `2025-12-01` | `2099-12-31` |
| `ro.board.api_level` | `202504` | both `202404` and `202504` appear |

This does not prove the bootloader rejected the image, but it is a real recovery userspace delta to clean up before claiming a boot-chain fix is complete.

## Answers

### Is stock recovery a standard Android boot image?

Yes. `file`, `unpack_bootimg.py`, and `magiskboot` all identify it as an Android boot image. It is Android boot image header v4 with a LZ4 legacy ramdisk and no kernel payload.

### Is OrangeFox packed using the same header version and layout?

Mostly yes at the boot image header level:

* both are Android boot image header v4
* both use page size `4096`
* both have `kernel_size=0`
* both use a LZ4 legacy ramdisk
* both have an empty command line
* both are exactly `104857600` bytes

But OrangeFox is not equivalent at the metadata/signing level:

* stock has no OS version or patch level in the boot header output
* OrangeFox has synthetic `99.87.36` / `2099-12`
* stock has a signed recovery AVB footer
* OrangeFox has an unsigned AVB footer with `Algorithm: NONE`

### Is OrangeFox missing an AVB footer or hash footer?

No. OrangeFox has an AVB hash footer at the end of the partition-sized image.

The failure is not "missing footer"; the failure is "footer does not match stock verification class":

* stock: `SHA256_RSA4096`, authentication block present, public key SHA-1 present, rollback index `1`
* OrangeFox: `Algorithm: NONE`, no authentication block, no public key, rollback index `0`

### Is OrangeFox missing bootconfig, cmdline, DTB, DTBO, or recovery_dtbo data?

No relative to stock recovery.

Both images show:

* empty command line
* no kernel component
* no DTB component reported by the boot image tools
* no recovery_dtbo component reported by the boot image tools
* no bootconfig emitted by available inspection tools

This means missing DTB/recovery_dtbo is not the primary format mismatch. Stock recovery also does not carry those components.

### Are there vendor ramdisk assumptions?

Yes, but not as a boot image vendor ramdisk section. These recovery images are not `vendor_boot` images and do not expose a vendor ramdisk table.

The vendor assumption is in userspace contents: OrangeFox carries vendor/odm recovery services and Android 16 prebuilts inside the recovery ramdisk, while stock recovery uses a smaller stock recovery userspace with specific `*.recovery` service names. That userspace mismatch is worth fixing, but the first hard packaging mismatch is AVB footer signing.

### Does stock recovery have an AVB footer or chained vbmeta expectation?

Stock recovery has its own AVB hash footer for partition name `recovery`.

Evidence:

```text
Algorithm:                SHA256_RSA4096
Rollback Index:           1
Rollback Index Location:  0
Partition Name:           recovery
Public key (sha1):        c25f7c19c9f1130b765425620028654fe8f591cf
```

This is self-contained recovery partition verification metadata. The image may still be part of a broader boot chain, but the stock recovery partition itself is not footerless.

### Did OrangeFox lose, change, or omit required footer/header metadata?

OrangeFox changed required AVB metadata:

* signed stock footer became unsigned `Algorithm: NONE`
* rollback index changed from `1` to `0`
* authentication block went from `576` bytes to `0`
* public key data is absent
* synthetic boot OS props were added to the recovery AVB footer
* synthetic boot header OS version and patch level were added

OrangeFox did not omit the footer and did not lose the Android boot image magic/header.

### Is the image exactly partition-sized but missing required structure at the end?

The image is exactly partition-sized, but it is not missing end structure.

Both images end with an `AVBf` footer at offset `0x063fffc0`. The OrangeFox end structure exists; it is just weaker/different than stock.

### Is the recovery partition booting this image directly, or does RM11 route recovery through another boot chain?

Evidence points to the recovery partition being a ramdisk-only recovery payload, not a standalone fastboot-bootable kernel image:

* stock `recovery_a` has `kernel_size=0`
* OrangeFox has `kernel_size=0`
* both are Android boot image v4 ramdisk-only images
* both lack DTB/recovery_dtbo payloads

Concrete inference: RM11 recovery boot likely uses the normal boot/vendor_boot kernel and device tree chain, then selects the recovery ramdisk from `recovery_a`/`recovery_b`. That makes `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img` a poor validation path for this image type and explains `Bad Buffer Size` as non-diagnostic for actual `recovery_a` flashing.

The real device-side failure remains: flashed `recovery_a` did not boot and routed to fastboot.

## Build-System Root Cause Candidate

The current device tree sets global AVB variables:

```make
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_ROLLBACK_INDEX_LOCATION := 1
```

It does not set recovery-specific AVB variables.

AOSP recovery image packaging uses:

```make
avbtool add_hash_footer \
  --image $(1) \
  --partition_name recovery \
  $(INTERNAL_AVB_RECOVERY_SIGNING_ARGS) \
  $(BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS)
```

`INTERNAL_AVB_RECOVERY_SIGNING_ARGS` is derived from `BOARD_AVB_RECOVERY_KEY_PATH` and `BOARD_AVB_RECOVERY_ALGORITHM`, not from the generic `BOARD_AVB_KEY_PATH` / `BOARD_AVB_ALGORITHM`.

That matches the observed output: OrangeFox got a recovery hash footer, but it was unsigned.

## Required Packaging Change Before Second Device Test

Do not retest the current image. The next image must differ and must pass pre-flash forensic checks.

Minimum concrete packaging change:

```make
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 0
```

Then rebuild and verify the new image before flashing:

```bash
avbtool info_image --image recovery.img
```

Required pre-flash output changes:

```text
Algorithm:                SHA256_RSA4096
Rollback Index:           1
Rollback Index Location:  0
Partition Name:           recovery
Authentication Block:     non-zero
```

Also remove or override the synthetic OrangeFox recovery metadata before another device test:

* do not emit `com.android.build.boot.os_version -> 99.87.36`
* do not emit `com.android.build.boot.security_patch -> 2099-12-31`
* avoid boot header `OS_VERSION [99.87.36]`
* avoid boot header `OS_PATCH_LEVEL [2099-12]`
* align recovery fingerprint/security metadata to the stock Android 16 RM11 baseline where the build system permits it

Important caveat: the stock private AVB key is not available in this workspace. Signing with AOSP testkey will produce a structurally correct signed footer, but it will not match the stock public key SHA-1 `c25f7c19c9f1130b765425620028654fe8f591cf`. A testkey-signed image is only a valid second test if the unlocked RM11 boot chain accepts it or if the vbmeta/verification path is intentionally adjusted and documented. Do not assume testkey equals stock-accepted.

## Additional Cleanup Before Calling The Next Build Boot-Ready

After the AVB footer is fixed, reconcile these userspace deltas:

* restore or consciously replace stock recovery-specific boot, health, fastbootd, and servicemanager recovery service files
* remove duplicate/conflicting `ro.board.api_level` values
* align Android 16 API/security patch properties with the stock baseline where possible
* review `recovery.fstab` against stock recovery and live Android block paths before flashing
* keep the rollback stock `recovery_a` image off-device and ready before any new test

## Current Classification

Current OrangeFox image classification remains:

```text
build-pass / flash-pass / boot-fail / rollback-pass
```

Do not publish it.

Do not retest the same image.

Do not call it bootable.

Next work is a packaging fix driven by this image-format forensic result, followed by a new hash and a controlled recovery flash test only after pre-flash `avbtool` output matches the required criteria above.

## Follow-Up: AVBTEST1 Built

AVBTEST1 was built after this report with recovery-specific AVB signing metadata.

Comparison report:

```text
docs/rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md
```

AVBTEST1 pre-flash verification:

```text
Algorithm:                SHA256_RSA4096
Authentication Block:     576 bytes
Rollback Index:           1
Rollback Index Location:  0
Partition Name:           recovery
```

AVBTEST1 remains unflashed and not boot-validated.
