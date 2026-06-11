# Coding-BR SM88XX Fox 14 NX809J Test Build - 2026-06-10

## Scope

This note records a local build experiment only. No device write, flash, boot
test, commit, or push was performed as part of this build note.

Reference tree:

```text
https://github.com/Coding-BR/android_device_zte_sm88XX-twrp
```

Local copied tree:

```text
/home/richtofen/android/repositories/MainAssets/fox_14.1/device/zte/sm88XX
```

Build tree:

```text
/home/richtofen/android/repositories/MainAssets/fox_14.1
```

The copied tree is not treated as a wholesale replacement for the existing
OrangeFox NX809J port. It is a separate same-generation sm8850/canoe test lane.

Do not copy the full local `device/zte/sm88XX` tree into the public dock repo
as-is. The local copy contains vendor `.so` libraries, firmware `.bin` payloads,
firmware image fragments, and vendor service binaries. Keep those local unless
there is a separate licensing/compliance decision.

## Local Build-Tree Changes

Text-only changes were made under the local Fox source tree:

```text
device/zte/sm88XX/AndroidProducts.mk
device/zte/sm88XX/BoardConfig.mk
device/zte/sm88XX/device.mk
device/zte/sm88XX/orangefox_NX809J_codingbr.mk
```

Important local adjustments:

- Added `orangefox_NX809J_codingbr-ap2a-eng` and
  `orangefox_NX809J_codingbr-ap2a-userdebug` lunch choices.
- Added `orangefox_NX809J_codingbr.mk`.
- Kept `PRODUCT_DEVICE := sm88XX` so Android uses
  `TARGET_DEVICE_DIR=device/zte/sm88XX` instead of the older local
  `device/nubia/NX809J` tree.
- Set system product identity to RM11 values:
  `PRODUCT_SYSTEM_DEVICE := NX809J`, `PRODUCT_SYSTEM_NAME := NX809J-UN`,
  `PRODUCT_SYSTEM_BRAND := REDMAGIC`, `PRODUCT_SYSTEM_MANUFACTURER := nubia`,
  and `PRODUCT_SYSTEM_MODEL := REDMAGIC 11 Pro`.
- Made `TARGET_BOOTLOADER_BOARD_NAME := canoe` explicit.
- Added recovery AVB footer settings:
  `BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096`,
  `BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1`,
  `BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 0`, and the local RM11
  recovery AVB test key path.
- Disabled Coding-BR's Android 16 / TWRP16 API-36 product forcing in
  `device.mk` so this OrangeFox 14.1 AP2A build base can evaluate the product
  config. This does not change the chipset target.

## Chipset And Device Build Vars

Verified with:

```text
cd /home/richtofen/android/repositories/MainAssets/fox_14.1
source build/envsetup.sh
lunch orangefox_NX809J_codingbr-ap2a-eng
```

Observed build vars:

```text
TARGET_PRODUCT=orangefox_NX809J_codingbr
TARGET_DEVICE=sm88XX
PRODUCT_DEVICE=sm88XX
PRODUCT_SYSTEM_DEVICE=NX809J
PRODUCT_SYSTEM_NAME=NX809J-UN
PRODUCT_SYSTEM_MODEL=REDMAGIC 11 Pro
PRODUCT_SYSTEM_BRAND=REDMAGIC
PRODUCT_SYSTEM_MANUFACTURER=nubia
TARGET_DEVICE_DIR=device/zte/sm88XX
TARGET_BOARD_PLATFORM=sm8850
PRODUCT_PLATFORM=canoe
TARGET_CPU_VARIANT_RUNTIME=oryon
TARGET_BOARD_PLATFORM_GPU=qcom-adreno840
TARGET_BOOTLOADER_BOARD_NAME=canoe
BOARD_BOOT_HEADER_VERSION=4
BOARD_RECOVERYIMAGE_PARTITION_SIZE=104857600
BOARD_RAMDISK_USE_LZ4=true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE=true
BOARD_AVB_RECOVERY_ALGORITHM=SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX=1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION=0
```

This confirms the local test lane targets the RM11 generation:
sm8850 / canoe / Oryon. It is not using the old RM10 Pro SoC identity.

## Build Command

```text
cd /home/richtofen/android/repositories/MainAssets/fox_14.1
source build/envsetup.sh
lunch orangefox_NX809J_codingbr-ap2a-eng
mka recoveryimage
```

Result:

```text
build completed successfully
```

## Artifacts

Output directory:

```text
/home/richtofen/android/repositories/MainAssets/fox_14.1/out/target/product/sm88XX
```

Files:

```text
44952206  ramdisk-recovery.img
104857600 recovery.img
104857600 OrangeFox-R12.0-Unofficial-NX809J.img
62802503  OrangeFox-R12.0-Unofficial-NX809J.zip
```

SHA256:

```text
f47569d341785c2db63000c1342f4c689d2ab5f2e5c3551feb77839e3b01e3ab  ramdisk-recovery.img
bac3d2ee0d85341e3729a0ac41822cbeb5266cbbd7ab2438d3fa50b5a7352820  recovery.img
bac3d2ee0d85341e3729a0ac41822cbeb5266cbbd7ab2438d3fa50b5a7352820  OrangeFox-R12.0-Unofficial-NX809J.img
63f080c09b614ae0020ac6842b09271d2b4609c5994eb83f00c93474439d6e33  OrangeFox-R12.0-Unofficial-NX809J.zip
```

Both `.img` files are exactly `104857600` bytes, matching the confirmed RM11
`recovery_a` partition size.

## Image Header

`unpack_bootimg.py` output for
`OrangeFox-R12.0-Unofficial-NX809J.img`:

```text
boot magic: ANDROID!
kernel_size: 0
ramdisk size: 44952206
os version: 99.87.36
os patch level: 2099-12
boot image header version: 4
command line args:
boot.img signature size: 0
```

This is still a standalone ramdisk-only recovery partition image. It is not a
`fastboot boot` RAM image.

## AVB Footer

`avbtool info_image` confirmed:

```text
Image size:               104857600 bytes
Original image size:      44957696 bytes
Public key (sha1):        0edd1a852e4dc1cecabb28e9061506fc62cf36a5
Algorithm:                SHA256_RSA4096
Rollback Index:           1
Rollback Index Location:  0
Partition Name:           recovery
```

This matches the local RM11 recovery test-key footer policy used by the earlier
AVBTEST1 lane. It is not an OEM signature.

## Generated Prop Caveat

Because `PRODUCT_DEVICE` must remain `sm88XX` to keep the Coding-BR BoardConfig
selected, generated props are mixed:

```text
ro.product.system.device=NX809J
ro.product.system.name=NX809J-UN
ro.product.system.model=REDMAGIC 11 Pro
ro.product.board=canoe
ro.board.platform=sm8850
ro.build.product=sm88XX
ro.product.vendor.device=sm88XX
ro.product.odm.device=sm88XX
ro.product.product.device=sm88XX
ro.product.system_ext.device=sm88XX
```

Attempting to force every partition prop to NX809J caused duplicate sysprop
build failures. Do not enable duplicate sysprop hacks just to make the text
look cleaner. For boot-first testing, the important verified lane is
`device/zte/sm88XX` + `sm8850` + `canoe` + RM11 system identity.

## Runtime Files Present

The generated ramdisk includes the Coding-BR runtime lane:

```text
init.recovery.qcom.rc
system/bin/unbind_inputs.sh
system/etc/recovery.fstab
system/etc/twrp.flags
vendor/bin/prepdecrypt.sh
vendor/etc/init/prepdecrypt.rc
```

No `.ko` vendor modules were present inside the generated ramdisk. The
`TW_LOAD_VENDOR_MODULES` list names `kmparam.ko panel_event_notifier.ko
zte_tpd.ko`, but this build did not package those module files into the
ramdisk.

## Safety Position

Status:

```text
build-pass / not device-tested / no boot proof / no touch proof / no decrypt proof
```

Do not describe this image as working recovery. The evidence only proves:

- the Coding-BR sm88XX tree can be built inside Fox 14.1;
- the target remains sm8850/canoe/Oryon;
- the output recovery image has the correct partition size;
- the output image has a signed AVB recovery footer using the local RM11 test
  key settings.

The next device-side test, if chosen, must still use the RM11 one-slot recovery
test policy with a verified rollback image ready. Standard `fastboot boot` is
not expected to work for this recovery layout.
