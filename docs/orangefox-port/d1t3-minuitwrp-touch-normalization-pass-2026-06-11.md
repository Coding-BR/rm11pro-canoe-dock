# Candidate D1T3 Minuitwrp Touch Normalization Pass

Date: 2026-06-11

Target: RM11 Pro / NX809J / canoe / sm8850

Source lane: Coding-BR sm88XX device tree inside local Fox 14.1

## Starting Evidence

D1 was not a boot failure. It reached full OrangeFox UI and root recovery ADB with decryption intentionally disabled.

D1T and D1T2 did not fix touch. Observed behavior:

- UI reached OrangeFox file/search/keyboard screens.
- Touch detection existed, but controls did not register reliably.
- The UI jumped between search, keyboard, and other screens.
- `synaptics_tcm_touch` reported a `12159 x 26879` ABS range, which is 10x the configured `1216 x 2688` screen size.
- D1T2 confirmed the input blacklist parser was fixed and noisy devices were blacklisted, but behavior did not improve.

Conclusion: noisy non-touch input filtering was not the main blocker. The next mechanism to test was minuitwrp touch normalization.

## Coding-BR Update Reviewed

The local reference clone was updated from `Coding-BR/android_device_zte_sm88XX-twrp`.

Relevant refs found:

- `origin/nx809j-touch-fix`
- `ca625a1 Fix NX809J touch mapping and add recovery build workflow`
- `bb6f5a8 Adjust NX809J recovery touch input`
- `3ee3f3b Use raw NX809J touch coordinates when axis max is bogus`

Important distinction:

- The Coding-BR README still listed fastbootd as not working at the time of this audit.
- The useful touch fix was in the TWRP build workflow patch against `bootable/recovery/minuitwrp/events.cpp`, not only in device-tree `BoardConfig.mk`.

## D1T3 Changes

D1T3 is based on D1T2 and keeps decryption disabled.

Source changes:

- Added a separate `orangefox_NX809J_codingbr_d1t3` product lane.
- Kept the D1/D1T/D1T2 no-decrypt runtime isolation.
- Kept `TW_NO_SCREEN_TIMEOUT := true`.
- Kept the colon/newline `TW_INPUT_BLACKLIST` parser fix from D1T2.
- Added Coding-BR/TWRP's NX809J minuitwrp touch normalization:
  - preserve `BTN_TOUCH` and `BTN_TOOL_FINGER` key events for touch handling;
  - bypass the standard ABS scaling path when the driver advertises a bogus large axis max but reports already screen-sized coordinates.

Exact patch:

- `docs/orangefox-port/candidate-diffs/candidate-d1t3-minuitwrp-touch-normalization.diff`
- `scripts/orangefox-sync/patches/patch-minuitwrp-nx809j-touch-fox_14.1.diff`

Touched files in the local Fox source:

- `bootable/recovery/minuitwrp/events.cpp`
- `device/zte/sm88XX/AndroidProducts.mk`
- `device/zte/sm88XX/BoardConfig.mk`
- `device/zte/sm88XX/orangefox_NX809J_codingbr_d1t3.mk`

## Build Result

Command:

```bash
cd "/home/richtofen/android/repositories/MainAssets/fox_14.1"
source build/envsetup.sh
lunch orangefox_NX809J_codingbr_d1t3-ap2a-eng
mka recoveryimage
```

The first pass hit the known Fox 14.1 `twres` packaging timing issue. The local workaround was:

```bash
cd "/home/richtofen/android/repositories/MainAssets/fox_14.1"
rm -rf out/target/product/sm88XX/recovery/root/twres
cp -a out/recovery/root/twres out/target/product/sm88XX/recovery/root/twres
source build/envsetup.sh
lunch orangefox_NX809J_codingbr_d1t3-ap2a-eng
mka recoveryimage
```

Result: pass.

Output image:

```text
/home/richtofen/android/repositories/MainAssets/recovery-forensics/d1t3-minuitwrp-touch-normalization/OrangeFox-R12.0-Unofficial-NX809J-d1t3-minuitwrp-touch-normalization.img
```

Artifact metadata:

```text
size: 104857600 bytes
sha256: 7c9bbc9f2e5f3253ebdaa0ea9dfe29bf4f13fc7035d38ac4912dd9b8643617c0
header version: 4
kernel size: 0
```

The image is exactly the RM11 recovery partition size: `104857600` bytes.

## Device Test Result

Test method:

- Rooted Android `dd` write to active `recovery_a` only.
- Partition hash verified after write.
- Booted recovery by `adb reboot recovery`.

Observed:

- OrangeFox booted.
- Root recovery ADB worked.
- Runtime marker was present:
  - `ro.rm11.touch_candidate_d1t3=d1t3-minuitwrp-touch-normalization`
- Screen timeout was disabled.
- Recovery log showed blacklisting for:
  - `goodix_fp`
  - `nubia_tgk_aw_sar0_ch0`
  - `nubia_tgk_aw_sar1_ch0`
  - `gpio-keys_nubia`
- User photo evidence showed successful navigation to:
  - Backup
  - Menu
  - Wipe
- User reported: "Works so far. Able to navigate just fine. Confident with screen lock now."

User-captured working UI logs are local-only:

```text
path: C:\temp\orangefox-d1t-working-ui-logs-20260611-175057.zip
size: 189520 bytes
sha256: dce4d916d6261d667a378eea56b28d57e19f725675628f6370ca10cfa2367d13
```

Interpretation:

- D1T3 is a basic boot/UI/ADB/touch-navigation pass.
- This does not prove decryption or any destructive/recovery-operation workflow.

## Still Unknown

Do not claim these as working from D1T3:

- `/data` decryption
- MTP
- fastbootd
- backup creation
- wipe/format execution
- install/flash execution
- USB OTG
- reboot menu behavior
- both-slot behavior
- long-session stability

## Rollback

Rollback remains the backed-up `recovery_a` image from before the test.

Do not write both recovery slots until the no-decrypt UI/touch lane and rollback path are independently repeatable.
