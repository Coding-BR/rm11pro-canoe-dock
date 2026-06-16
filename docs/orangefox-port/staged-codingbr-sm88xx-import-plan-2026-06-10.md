# Staged Coding-BR SM88XX Import Plan - 2026-06-10

## Scope

Reference:

```text
https://github.com/Coding-BR/android_device_zte_sm88XX-twrp
```

Local reference clone:

```text
<local-build-root>/references/codingbr_zte_sm88xx_twrp
```

Reference commit inspected:

```text
69ed00e Update README touchscreen status
```

Compared against:

```text
<repo-root>/recovery/device/zte/sm88XX
```

No build, flash, device write, commit, push, or source-tree patch was performed.
The files under `candidate-diffs/` are review diffs only.

## Re-evaluation

Treat the Coding-BR tree as a high-value same-generation reference, not just a
generic decrypt hint. Its README explicitly lists RedMagic 11 Pro support and
states that touchscreen was tested on REDMAGIC 11 Pro / NX809J, with
`synaptics_tcm_touch` coordinate mapping fixed.

Do not over-focus on the earlier cropped recovery UI report. That screenshot
came from a previous experimental recovery flash and is not proven to represent
the current OrangeFox tree. The current blocker remains staged validation:
boot to UI or recovery ADB first, then touch/input, then decryption.

## High-confidence Matches

- `PRODUCT_PLATFORM := canoe`
- `TARGET_CPU_VARIANT_RUNTIME := oryon`
- `BOARD_BOOT_HEADER_VERSION := 4`
- `BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600`
- `BOARD_RAMDISK_USE_LZ4 := true`
- `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`
- `TW_FRAMERATE := 120`
- `TW_BRIGHTNESS_PATH := /sys/class/backlight/panel0-backlight/brightness`
- `TW_MAX_BRIGHTNESS := 8190`
- QCOM FBE flags are already present in Canoe Dock.

## Important Differences

| Area | Canoe Dock current | Coding-BR reference | Import decision |
|---|---|---|---|
| Board platform | `TARGET_BOARD_PLATFORM := canoe` | `TARGET_BOARD_PLATFORM := sm8850` | Candidate A changes build SoC identity to `sm8850` while keeping product identity `canoe`. |
| Screen geometry | missing explicit `TW_SCREEN_W/H` and `TARGET_SCREEN_WIDTH/HEIGHT` | `1216 x 2688` | Candidate B imports explicit dimensions. |
| Screen blanking | `TW_SCREEN_BLANK_ON_BOOT := true` | `false` | Candidate B changes to `false`. |
| Default brightness | `250` | `1500` | Candidate B changes to `1500`. |
| Input blacklist | includes `hbtp_vm` and an extra `canoe-mtp-snd-card` pair | includes `gpio-keys_nubia`; no `hbtp_vm` | Candidate B matches the NX809J-tested reference list. |
| Input cleanup | absent | `unbind_inputs.sh` removes `goodix_fp` and Nubia SAR input nodes | Candidate B adds it, deferred until `twrp.modules.loaded=true`. |
| Vendor modules | broad live-confirmed list | `kmparam.ko panel_event_notifier.ko zte_tpd.ko` | Do not import `kmparam.ko` until found on this NX809J payload. |
| Runtime decrypt | minimal init, no `prepdecrypt` | active `prepdecrypt.vendor` path | Candidate C adds it after boot/touch validation. |
| Fstab | stock-derived boot-safe fstab | broad TWRP fstab with EROFS alternates and metadata encryption | Candidate C changes only `/data` encryption flags, not the full fstab. |
| `vendor.keymint-strongbox` | no service found | init starts it but no matching service definition found | Do not start an undefined service; keep live NX809J onekeymint path. |

## Candidate Diffs

### Candidate A: Boot-safe SM8850/canoe Identity Correction

Diff:

```text
docs/orangefox-port/candidate-diffs/candidate-a-sm8850-canoe-identity.diff
```

Touched files:

```text
recovery/device/zte/sm88XX/BoardConfig.mk
```

Changes:

- `TARGET_BOARD_PLATFORM := sm8850`
- `QCOM_BOARD_PLATFORMS += sm8850`
- Keeps `PRODUCT_PLATFORM := canoe`.
- Keeps existing recovery header v4, LZ4 ramdisk, no-kernel recovery layout,
  partition size, and stock-minimal init/fstab.

Validation:

```text
git diff --check: clean
```

Rollback:

```text
git apply -R docs/orangefox-port/candidate-diffs/candidate-a-sm8850-canoe-identity.diff
```

### Candidate B: Display/touch/input Correction

Diff:

```text
docs/orangefox-port/candidate-diffs/candidate-b-display-touch-input.diff
```

Touched files:

```text
recovery/device/zte/sm88XX/BoardConfig.mk
recovery/device/zte/sm88XX/device.mk
recovery/device/zte/sm88XX/recovery/root/init.recovery.qcom.rc
recovery/device/zte/sm88XX/recovery/root/system/bin/unbind_inputs.sh
```

Changes:

- Adds explicit `1216 x 2688` TWRP dimensions.
- Changes default brightness to `1500`.
- Changes `TW_SCREEN_BLANK_ON_BOOT` to `false`.
- Matches the Coding-BR NX809J-tested input blacklist.
- Adds `unbind_inputs.sh` for `goodix_fp`, `nubia_tgk_aw_sar0_ch0`, and
  `nubia_tgk_aw_sar1_ch0`.
- Starts the cleanup helper only after `twrp.modules.loaded=true`.

Validation:

```text
git diff --check: clean
```

Rollback:

```text
git apply -R docs/orangefox-port/candidate-diffs/candidate-b-display-touch-input.diff
```

### Candidate C: Decryption Runtime Lane

Diff:

```text
docs/orangefox-port/candidate-diffs/candidate-c-decryption-runtime-lane.diff
```

Touched files:

```text
recovery/device/zte/sm88XX/device.mk
recovery/device/zte/sm88XX/recovery.fstab
recovery/device/zte/sm88XX/recovery/root/init.recovery.qcom.rc
recovery/device/zte/sm88XX/recovery/root/system/etc/twrp.flags
recovery/device/zte/sm88XX/recovery/root/vendor/bin/prepdecrypt.sh
recovery/device/zte/sm88XX/recovery/root/vendor/etc/init/prepdecrypt.rc
```

Changes:

- Adds `prepdecrypt.vendor` service and script.
- Adjusts `prepdecrypt` fallback values to this tree's current
  `PLATFORM_VERSION := 14` and `PLATFORM_SECURITY_PATCH := 2025-12-01`.
- Starts `vendor.gatekeeper_default` on early init.
- Sets `prepdecrypt.setpatch true`.
- Mounts modem firmware and marks firmware as `mounttodecrypt`.
- Starts `prepdecrypt.vendor` only when encrypted dynamic partitions are present.
- Changes `/data` from the stock recovery `fileencryption=ice,wrappedkey` style
  to the Coding-BR metadata-encryption form.
- Does not replace the full fstab and does not import EROFS alternates or
  broad physical partition entries into the boot-proving candidate.

Validation:

```text
git diff --check: clean
```

Rollback:

```text
git apply -R docs/orangefox-port/candidate-diffs/candidate-c-decryption-runtime-lane.diff
```

## Do Not Import Yet

- Do not import reference `.so`, firmware, or vendor binaries into the public
  dock repo.
- Do not switch to `kmparam.ko` until it is found in this NX809J firmware set.
- Do not import Coding-BR `libinit_zte_sm88XX` unchanged. It rewrites NX809J
  product properties to `RedMagic_11_Pro`, while local live evidence records
  `ro.product.device=NX809J` and `ro.product.name=NX809J-UN`.
- Do not use the Coding-BR fastboot flash instructions as RM11 test policy.
  Current RM11 evidence still favors rooted-Android one-slot `dd` recovery tests.

## Recommended Order

1. Apply Candidate A only, build, inspect image, and test one slot with a stock
   recovery backup ready.
2. If Candidate A reaches UI or recovery ADB, apply Candidate B and validate
   display, touch, and noisy input handling.
3. If A and B are confirmed, apply Candidate C and validate `/metadata`, `/data`,
   `prepdecrypt`, keymint/gatekeeper logs, MTP, and reboot behavior.

WEIGH IT AGAIN = TESSERACT: repeated success only counts when each candidate is
tested independently with image headers, recovery logs, ADB state, and rollback
hashes captured.
