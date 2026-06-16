# RM11 Pro Live ADB Baseline

Evidence source: connected REDMAGIC 11 Pro / NX809J running Android 16 with Magisk root, captured on 2026-06-07 before the OP-WILD KernelSU-Next/SUSFS kernel validation.

This is not a recovery boot validation. It is a live Android baseline used to keep the recovery port tree aligned with the actual device.

## Device Identity

| Key | Value |
|-----|-------|
| `ro.product.device` | `NX809J` |
| `ro.product.model` | `NX809J` |
| `ro.product.name` | `NX809J-UN` |
| `ro.product.board` | `canoe` |
| `ro.board.platform` | `canoe` |
| `ro.board.api_level` | `202504` |
| `ro.product.first_api_level` | `36` |
| `ro.build.version.sdk` | `36` |
| Active slot | `_a` |
| Verified boot state | `orange` |
| Boot device | `1d84000.ufshc` |
| DTBO index | `26` |
| DTB index | `7` |

Android kernel at baseline capture:

```text
6.12.23-android16-5-gf1bdb13583da-ab13761046-4k
```

Root context:

```text
u:r:magisk:s0
```

Post-KernelSU live Android state is recorded separately in [`rm11-post-ksun-adb-sanity.md`](rm11-post-ksun-adb-sanity.md).

## Partition Sizes

| Partition | Live size |
|-----------|-----------|
| `boot_a` | `100663296` |
| `init_boot_a` | `8388608` |
| `vendor_boot_a` | `100663296` |
| `recovery_a` | `104857600` |
| `dtbo_a` | `75497472` |
| `super` | `19327352832` |

Live partition hashes captured before recovery work:

```text
recovery_a  694eba1214ff90f1da496c2108e98479167b15f3f7eb631deb64493402303394
recovery_b  694eba1214ff90f1da496c2108e98479167b15f3f7eb631deb64493402303394
dtbo_a      e2f0c6184c507e6d88a5c53ded2356e9bf9e81388a268df19398a0868e2b3263
```

## Display And Input

Backlight path:

```text
/sys/class/backlight/panel0-backlight/brightness
```

Backlight max:

```text
8190
```

Touch input:

```text
name: synaptics_tcm_touch
event: /dev/input/event9
ABS_X max: 12159
ABS_Y max: 26879
ABS_MT_POSITION_X max: 12159
ABS_MT_POSITION_Y max: 26879
```

Non-touch input devices confirmed on Android:

```text
goodix_fp
nubia_tgk_aw_sar0_ch0
nubia_tgk_aw_sar1_ch0
canoe-mtp-wsa884x-snd-card Headset Jack
canoe-mtp-wsa884x-snd-card Button Jack
```

## Recovery-Relevant Modules

All modules currently listed in `TW_LOAD_VENDOR_MODULES` exist on the live device under `/vendor_dlkm/lib/modules`:

```text
drm_display_helper.ko
msm_drm.ko
msm_ext_display.ko
panel_event_notifier.ko
zte_tpd.ko
aw9620x.ko
aw86320.ko
haptic_86938.ko
zte_fingerprint.ko
```

## Android 16 Recovery Prebuilts

Live Android 16 files were pulled into `prebuilt/android16/` for recovery build inputs:

- `dtbo.img` from `/dev/block/by-name/dtbo_a`
- system keystore userspace files from `/system`
- vendor onekeymint, gatekeeper, qsee init files and manifests from `/vendor/etc`
- vendor onekeymint, gatekeeper, qsee service binaries from `/vendor/bin`
- vendor keymint, gatekeeper, qsee support libraries from `/vendor/lib64`

The old inherited prebuilt files were left in place for comparison. Build wiring now points at the Android 16 set where explicit copy paths exist.

## Fstab Notes

The live `/vendor/etc/fstab.qcom` confirms:

- EROFS logical partitions for `system`, `system_ext`, `product`, `vendor`, `vendor_dlkm`, `system_dlkm`, and `odm`.
- F2FS `/data` with metadata encryption.
- `sysfs_path=/sys/devices/platform/soc/1d84000.ufshc` for userdata.
- Physical boot partitions for `boot`, `init_boot`, `vendor_boot`, `dtbo`, and `recovery`.

## Remaining Recovery Evidence Needed

- First OrangeFox boot log from recovery.
- Recovery touch behavior after `zte_tpd.ko` loads.
- Recovery ADB behavior.
- Decryption result on Android 16 FBE metadata.
- Fastbootd and USB OTG behavior from recovery.
