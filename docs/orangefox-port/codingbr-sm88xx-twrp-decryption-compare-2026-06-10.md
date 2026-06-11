# Coding-BR SM88XX TWRP Decryption Compare - 2026-06-10

Superseded for implementation planning by:

```text
staged-codingbr-sm88xx-import-plan-2026-06-10.md
```

This earlier note treated Coding-BR primarily as a decryption reference. The
new staged plan treats it as a high-value same-generation RedMagic 11 Pro /
NX809J / sm8850 reference while still avoiding a wholesale tree replacement.

## Scope

Reference repo:

```text
https://github.com/Coding-BR/android_device_zte_sm88XX-twrp
```

Reference commit inspected:

```text
69ed00e Update README touchscreen status
```

Local reference clone:

```text
/home/richtofen/android/repositories/MainAssets/references/codingbr_zte_sm88xx_twrp
```

Compared against:

```text
/home/richtofen/android/repositories/rm11pro-canoe-dock/ports/orangefox-recovery/device_nubia_NX809J
```

No build, flash, or device write was performed for this comparison.

## Headline

This repo is useful. It is not a drop-in replacement.

It appears to solve the later TWRP/OrangeFox decryption lane by carrying the
missing recovery-root runtime pieces:

- QCOM FBE flags.
- `prepdecrypt.vendor`.
- qseecomd.
- gatekeeper.
- keymint / onekeymint.
- health service.
- firmware mount for decrypt.
- TWRP `twrp.flags` entries with `mounttodecrypt`.
- vendor lib/bin payloads required by the security stack.

The active Canoe Dock OrangeFox tree already has the build-time crypto flags
and several qsee/gatekeeper/keymint text stubs. The biggest gap is the runtime
start path and associated vendor payload set.

## Do Not Copy Blindly

Keep these differences in mind:

| Area | Coding-BR tree | Canoe Dock current position | Decision |
|---|---|---|---|
| Device scope | generic `device/zte/sm88XX` for NX809J and NX741J | device-specific `device/nubia/NX809J` | keep NX809J-specific tree |
| Platform | `TARGET_BOARD_PLATFORM := sm8850` | `TARGET_BOARD_PLATFORM := canoe` from live evidence | keep `canoe` unless build system requires SoC platform alias |
| Super partition size | `18907922432` | `19327352832` from local/IronShing evidence | keep Canoe Dock values |
| Fastboot recovery instructions | says `fastboot flash recovery` / both slots | RM11 evidence says standard `fastboot boot` is not useful and recovery testing should be rooted-Android `dd` | keep Canoe Dock one-slot test rule |
| Product properties | libinit maps NX809J to `RedMagic_11_Pro` device | live RM11 evidence reports `ro.product.device=NX809J`, `ro.product.name=NX809J-UN` | do not import property override unchanged |
| Build metadata | TWRP defaults `99.87.36` / `2099-12-31` | Canoe Dock candidate uses Android 14/2025-12 recovery metadata for the current OrangeFox base | keep current metadata; use `prepdecrypt.setpatch` only when testing decrypt |
| Vendor blobs | ships many `.so`, firmware, and vendor binaries | public dock excludes blobs | keep blobs local-only |

## What Matches Already

Canoe Dock already has:

- `TW_INCLUDE_CRYPTO := true`
- `TW_INCLUDE_CRYPTO_FBE := true`
- `TW_INCLUDE_FBE_METADATA_DECRYPT := true`
- `BOARD_USES_QCOM_FBE_DECRYPTION := true`
- `BOARD_USES_METADATA_PARTITION := true`
- `TW_USE_FSCRYPT_POLICY := 2`
- qsee/gatekeeper/keymint-related text under `recovery/root/vendor/etc/init`
- local Android 16 prebuilt notes and manifests

So this is not a simple missing-flag problem.

## Useful Coding-BR Pieces

### Runtime Decryption Start Path

Coding-BR `init.recovery.qcom.rc` adds these recovery runtime hooks:

```text
on early-init
    start vendor.gatekeeper_default

on init
    write /sys/fs/selinux/checkreqprot 0
    setprop prepdecrypt.setpatch true

on fs
    write /proc/sys/kernel/firmware_config/force_sysfs_fallback 1

on property:twrp.modules.loaded=true
    mount modem firmware
    write /sys/kernel/boot_adsp/ssr 1
    start vendor.health-default
    start unbind_inputs

on property:ro.crypto.state=encrypted && property:ro.boot.dynamic_partitions=true
    start prepdecrypt.vendor

on property:vendor.sys.listeners.registered=true
    start vendor.keymint-strongbox
```

These are decryption-relevant, but they should not all be reintroduced into the
next bootability candidate. The previous RM11 test hung at the RedMagic logo
after an aggressive init/fstab path. Bring them back only after UI or recovery
ADB is reached.

### prepdecrypt

Coding-BR includes:

```text
recovery/root/vendor/etc/init/prepdecrypt.rc
recovery/root/vendor/bin/prepdecrypt.sh
```

The script:

- checks `ro.crypto.type`;
- handles dynamic partitions;
- temp-mounts system/vendor;
- updates recovery properties from real system/vendor build props;
- sets `crypto.ready=1`.

This is likely the core reusable decryption mechanism.

### Vendor Security Services

Useful service definitions:

```text
vendor/etc/init/qseecomd.rc
vendor/etc/init/android.hardware.gatekeeper-service-qti.rc
vendor/etc/init/android.hardware.security.keymint-service-qti.rc
vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc
vendor/etc/init/android.hardware.health-service.qti.rc
```

Canoe Dock already has some of these, but not identical:

- Coding-BR qsee/gatekeeper uses explicit `seclabel u:r:recovery:s0`.
- Coding-BR gatekeeper path is `android.hardware.gatekeeper-service-spu-qti`.
- Canoe Dock gatekeeper path is currently `android.hardware.gatekeeper-rust-service-qti`.
- Coding-BR includes an active `onekeymint` init file.
- Canoe Dock currently notes that one-keymint is live Android behavior but does
  not carry that init file in the tracked public snapshot.

For NX809J, prefer live-stock Android 16 service names over generic sm88XX if
they differ.

### TWRP Flags

Coding-BR `system/etc/twrp.flags` adds:

```text
/firmware vfat /dev/block/bootdevice/by-name/modem flags=slotselect;display="Firmware";mounttodecrypt;...
/metadata f2fs /dev/block/by-name/metadata flags=display="Metadata";backup=1;flashimg=1
/boot, /init_boot, /vendor_boot, /recovery, /dtbo, /vbmeta, /vbmeta_system
```

The `mounttodecrypt` firmware row is likely useful once recovery reaches UI/ADB.

### Fstab

Coding-BR uses a broad TWRP fstab with:

- ext4 and EROFS logical partition alternates;
- full Android FBE metadata encryption strings for `/data`;
- `vendor_dlkm` and `system_dlkm`;
- `vendor_boot` entry for backup/flash UI.

Canoe Dock currently keeps the fstab close to stock standalone recovery because
the previous broader fstab/init candidate hung. Do not replace it wholesale
before proving the minimal candidate reaches UI or recovery ADB.

### Touch/Input

Coding-BR claims touchscreen works and includes:

```text
recovery/root/system/bin/unbind_inputs.sh
```

It removes noisy fingerprint/shoulder-trigger input nodes and restarts
`recovery` after module load. This may explain their working touch status, but
it is not needed to prove initial boot/ADB.

## Recommended Candidate Order

### Candidate A: Boot-Minimal Retest

Goal:

```text
Reach OrangeFox/TWRP UI or recovery ADB.
```

Keep:

- stock-derived `recovery.fstab`;
- stock-minimal `init.recovery.qcom.rc`;
- one-slot `recovery_a` rooted-Android dd test only;
- current AVB recovery footer metadata.

Consider before rebuilding:

- reduce `TW_LOAD_VENDOR_MODULES` to the smallest NX809J-confirmed set needed
  for touch after UI.
- do not add decrypt services yet.

Reason:

Bootability is the current blocker. Decryption cannot be validated until
recovery userspace is alive.

### Candidate B: Decryption Runtime Candidate

Only after Candidate A reaches UI/ADB, add:

- `prepdecrypt.rc`
- `prepdecrypt.sh`
- `prepdecrypt.setpatch true`
- qsee/gatekeeper/onekeymint start path using NX809J live Android 16 service names
- firmware `mounttodecrypt` row in `twrp.flags`
- firmware mount + ADSP kick from Coding-BR if needed

Then validate:

- `/metadata` mount;
- `/data` decrypt prompt;
- `crypto.ready`;
- recovery log entries from `prepdecrypt`;
- MTP after decrypt;
- reboot to Android.

## Unknowns Needing Evidence

- Whether `kmparam.ko` exists on this NX809J firmware. It was in the Coding-BR
  module list but was not found in the current local prebuilts/docs.
- Whether Canoe Dock should use `android.hardware.gatekeeper-service-spu-qti`
  or `android.hardware.gatekeeper-rust-service-qti`; live Android evidence
  should decide.
- Whether `TARGET_INIT_VENDOR_LIB` helps NX809J or changes product properties in
  a way that breaks assertions.
- Whether the broad Coding-BR fstab boots on this exact OrangeFox build base.
- Whether Coding-BR's decryption claim was validated on RM11 Pro only, Z80
  Ultra only, or both.

## Current Takeaway

Coding-BR provides the best local decryption recipe so far, but the next active
RM11 OrangeFox step should still be bootability first. Once UI or recovery ADB
works, port the decryption runtime pieces in a controlled second candidate.
