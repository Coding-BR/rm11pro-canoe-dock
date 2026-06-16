# OrangeFox Recovery - REDMAGIC 11 Pro (NX809J)

> RM11 Pro / NX809J OrangeFox recovery port. The upstream ancestry is the REDMAGIC 10 Pro tree; active-device labels in this fork should stay RM11 Pro / NX809J.

![OrangeFox](https://img.shields.io/badge/OrangeFox-14.1-orange?style=flat-square)
![Device](https://img.shields.io/badge/Device-REDMAGIC%2011%20Pro-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Port%20WIP-yellow?style=flat-square)

## Device Specifications

| Feature | Details |
|---------|---------|
| Device | REDMAGIC 11 Pro |
| Codename | NX809J |
| Board/platform | canoe |
| SoC family | Snapdragon 8 Elite Gen 5 |
| GPU | Adreno 840 |
| Architecture | arm64 |
| Android base | Android 16 / API 36 |
| A/B partitions | Yes |
| Dynamic partitions | Yes |
| Dynamic group | `qti_dynamic_partitions` |
| Encryption | FBE / metadata encryption / inline crypto |
| Recovery partition | Yes (`recovery_a` / `recovery_b`) |

## Current Status

This branch is an NX809J port with stock image evidence and live Android ADB evidence applied. It builds successfully and flashed to `recovery_a`, but the first OrangeFox boot test failed and routed the device to fastboot. Stock `recovery_a` rollback succeeded and Android boot was restored.

AVBTEST1 was rebuilt after the image-format forensic pass with recovery-specific AVB signing metadata. It has not been flashed or boot-tested.

| Feature | Status |
|---------|--------|
| Build | PASS (`OrangeFox-R12.0-Unofficial-NX809J.img` / `.zip`) |
| AVBTEST1 rebuild | PASS; pre-flash image verification passed |
| `fastboot boot` | FAIL (`Bad Buffer Size`) |
| Flash `recovery_a` | PASS |
| Boot to OrangeFox recovery | FAIL, routed to fastboot |
| Stock `recovery_a` rollback | PASS, Android boot restored |
| Image format forensics | DONE; AVB footer/signing mismatch identified |
| Current classification | `build-pass / flash-pass-old / boot-fail-old / rollback-pass / avb-signed rebuild ready for cautious test` |
| OrangeFox UI | Not reached |
| Touch | Android input baseline captured; recovery not validated |
| ADB | Android root baseline captured; recovery not validated |
| Decryption (FBE) | Not validated |
| Flashing ZIPs | Not validated |
| Backup / Restore | Not validated |
| Fastbootd | Not validated |
| USB OTG | Not validated |

## Port Evidence Used

- Stock `recovery.img` and `vendor_boot.img` contain NX809J Android 16 fingerprints.
- Stock `prop.default` reports `ro.board.platform=canoe`, `ro.product.first_api_level=36`, and `ro.board.api_level=202504`.
- Stock `vendor_boot` DTB reports Qualcomm `alor` base with `canoe` compatibles and Adreno 840 strings.
- Live Android ADB baseline is recorded in [`docs/rm11-live-adb-baseline.md`](docs/rm11-live-adb-baseline.md).
- Stock rawprogram XML reports:
  - `boot`: 100663296 bytes
  - `vendor_boot`: 100663296 bytes
  - `recovery`: 104857600 bytes
  - `dtbo`: 75497472 bytes
  - `init_boot`: 8388608 bytes
  - `super`: 19327352832 bytes
- Stock `fstab.qcom` reports EROFS logical partitions and Android 16 metadata encryption flags.
- Live Android reports `panel0-backlight` max brightness `8190`, `synaptics_tcm_touch`, `goodix_fp`, `nubia_tgk_aw_sar*`, and `canoe-mtp-wsa884x-snd-card` jack input names.
- Live Android confirms the recovery-focused vendor module names currently listed in `TW_LOAD_VENDOR_MODULES` exist under `/vendor_dlkm/lib/modules`.
- Live Android 16 DTBO and crypto/qsee prebuilts are staged under `prebuilt/android16/`.
- Post-KernelSU live Android state is recorded in [`docs/rm11-post-ksun-adb-sanity.md`](docs/rm11-post-ksun-adb-sanity.md); it confirms the current Android-side root context is KernelSU (`u:r:ksu:s0`), not Magisk.
- OrangeFox build evidence is recorded in [`docs/rm11-orangefox-build-pass-2026-06-07.md`](docs/rm11-orangefox-build-pass-2026-06-07.md).
- OrangeFox failed boot and rollback evidence is recorded in [`docs/rm11-orangefox-flash-pass-boot-fail-rollback-pass-2026-06-07.md`](docs/rm11-orangefox-flash-pass-boot-fail-rollback-pass-2026-06-07.md).
- Recovery image/header forensics are recorded in [`docs/rm11-orangefox-image-format-forensics-2026-06-07.md`](docs/rm11-orangefox-image-format-forensics-2026-06-07.md). Stock and OrangeFox are both Android boot image header v4 ramdisk-only recovery images, but stock has a signed `SHA256_RSA4096` recovery AVB footer and the failed OrangeFox image has `Algorithm: NONE`.
- AVBTEST1 comparison evidence is recorded in [`docs/rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md`](docs/rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md). AVBTEST1 fixes the hard footer mismatch: `SHA256_RSA4096`, rollback index `1`, rollback location `0`, and auth block present.

## Important Unknowns

- Decryption is not solved yet. Android 16 system keystore, vendor onekeymint, gatekeeper, qsee, and related libraries are wired from `prebuilt/android16/`, but recovery-side FBE has not been boot-tested.
- Vendor blobs and HAL services are still inherited from the RM10 tree unless explicitly replaced in `device.mk`.
- The experimental NX809J kernel work is useful context, but this tree currently uses stock RM11 prebuilts as the baseline.
- Recovery boot failed on the first test image. Live Android properties, by-name links, input device names, loaded modules, and basic sysfs paths have been captured. AVBTEST1 fixes the unsigned recovery footer mismatch but still uses a generated validation key, not the stock/OEM key.
- The local OrangeFox source tree now exists at `~/fox_14.1`; build validation passed on 2026-06-07.
- Do not publish or retest the original failed OrangeFox image. The next eligible device-side test is the AVBTEST1 image only, and only as a cautious controlled test with stock `recovery_a` rollback ready.

## Building

### Requirements

- Ubuntu 20.04 / 22.04 / 24.04
- At least 16GB RAM
- At least 150GB free disk space
- OpenJDK 11

### Install dependencies

```bash
sudo apt update && sudo apt install -y \
  git curl wget python3 python-is-python3 \
  bc bison build-essential ccache flex \
  g++-multilib gcc-multilib gnupg gperf \
  imagemagick lib32ncurses-dev lib32readline-dev \
  lib32z1-dev lz4 libncurses-dev libsdl1.2-dev \
  libssl-dev libwxgtk3.2-dev libxml2-dev \
  libxml2-utils lzop pngcrush rsync schedtool \
  squashfs-tools xsltproc zip zlib1g-dev openjdk-11-jdk
```

### Sync OrangeFox source

```bash
git clone https://gitlab.com/OrangeFox/sync.git ~/OrangeFox_sync
cd ~/OrangeFox_sync
./orangefox_sync.sh --branch 14.1 --path ~/fox_14.1
```

### Place device tree

```bash
mkdir -p ~/fox_14.1/device/nubia
git clone https://github.com/Fractal-Echo/rm11pro-canoe-dock ~/rm11pro-canoe-dock
# Do not use --delete here; the local tree also holds untracked prebuilts and AVB test keys.
rsync -a ~/rm11pro-canoe-dock/recovery/device/zte/sm88XX/ ~/fox_14.1/device/nubia/NX809J/
```

### Build

```bash
cd ~/fox_14.1
source build/envsetup.sh
lunch orangefox_NX809J-ap2a-eng
mka adbd recoveryimage
```

Output should be at:

```text
out/target/product/NX809J/recovery.img
```

## Flashing

Do not flash the original failed OrangeFox image again. The 2026-06-07 build flashed to `recovery_a` but failed to boot recovery and routed to fastboot. AVBTEST1 fixes the unsigned recovery footer mismatch and is ready only for a cautious controlled test. Keep stock `recovery_a` rollback available before any flash.

From Android with root:

```bash
adb push recovery.img /sdcard/recovery.img
adb shell su -c "dd if=/sdcard/recovery.img of=/dev/block/bootdevice/by-name/recovery_a"
adb shell su -c "dd if=/sdcard/recovery.img of=/dev/block/bootdevice/by-name/recovery_b"
adb reboot recovery
```

## Credits

- [OrangeFox Recovery Project](https://orangefox.download)
- [TeamWin (TWRP)](https://twrp.me)
- REDMAGIC 10 Pro OrangeFox base by plompomg
- REDMAGIC 11 Pro port work by Fractal-Echo

## License

```text
Copyright (C) 2025 The Android Open Source Project

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
```
