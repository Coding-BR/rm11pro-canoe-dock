# Candidate D1T Touch/Input Isolation

Date: 2026-06-11

Target: RM11 Pro / NX809J / canoe / sm8850

## Starting Evidence

Candidate D1 was not a boot failure. It reached full OrangeFox UI and recovery ADB with decrypt intentionally disabled.

Observed D1 issue:
- Touch worked partially before timeout.
- The device reached the OrangeFox lock/screen-saver overlay.
- The visible overlay said: `Swipe up from the bottom of the screen to Unlock`.
- Swipe-up from the bottom was not detected correctly.

Interpretation:
- Graphics and recovery process startup are good enough for UI testing.
- The immediate blocker is touch/input behavior around bottom-edge gestures, lock overlay, or sleep/wake input reinitialization.
- Decryption is still intentionally out of scope for this candidate.

## D1T Changes

D1T adds a separate `orangefox_NX809J_codingbr_d1t` product lane on top of D1.

Changed areas:
- Keep D1 no-decrypt runtime isolation.
- Add `TW_NO_SCREEN_TIMEOUT := true` for D1T.
- Keep existing `TW_NO_SCREEN_BLANK := true`.
- Keep existing `TW_SCREEN_BLANK_ON_BOOT := false`.
- Add a D1T-specific input blacklist using newline separators supported by this recovery source parser.
- Add a D1T-specific `unbind_inputs.sh` overlay that removes known non-touch inputs while leaving `synaptics_tcm_touch` alone.

Not changed:
- No decrypt/keymint/gatekeeper/qsee/weaver changes.
- No fstab changes.
- No recovery image layout changes.
- No boot, vendor_boot, or init_boot changes.
- No touchscreen swap/flip/rotation flags yet.

## Build Result

Command:

```bash
cd /home/richtofen/android/repositories/MainAssets/fox_14.1
source build/envsetup.sh
export TARGET_PRODUCT=orangefox_NX809J_codingbr_d1t
export TARGET_RELEASE=ap2a
export TARGET_BUILD_VARIANT=eng
mka recoveryimage
```

Result: pass.

Note: OrangeFox post-build packaging still tries to write `/OrangeFox-R12.0-Unofficial-NX809J.img`, `/OrangeFox-R12.0-Unofficial-NX809J.zip`, and `/FOX_AIK` at filesystem root. That fails in WSL because `/` is read-only for those writes. The actual recovery image is still produced at `out/target/product/sm88XX/recovery.img`.

Preserved test image:

```text
/home/richtofen/android/repositories/MainAssets/recovery-forensics/d1t-touch-input-isolation/OrangeFox-R12.0-Unofficial-NX809J-d1t-touch-input-isolation.img
```

Artifact metadata:

```text
size: 104857600 bytes
sha256: 9686d9a5415a7e7a67bb623c7e9661e086bf5f356a7902cbd7df0051aab34bbb
kernel_size: 0
ramdisk size: 40058939
header version: 4
os version: 99.87.36
os patch level: 2099-12
```

The image is exactly the RM11 recovery partition size: `104857600` bytes.

## Touch Range Check Needed During Test

ADB was not visible from WSL after this build, so actual `getevent` ranges were not captured yet.

During the next recovery test, capture the Synaptics ABS ranges:

```bash
adb shell 'for e in /dev/input/event*; do n=$(getevent -i "$e" 2>/dev/null | sed -n "s/^  name: *\"\(.*\)\"/\1/p"); [ "$n" = synaptics_tcm_touch ] && echo "$e $n" && getevent -lp "$e" 2>/dev/null | sed -n "/ABS_MT_POSITION_X/,+5p;/ABS_MT_POSITION_Y/,+5p"; done'
```

Expected if screen and touch space match the current config:

```text
ABS_MT_POSITION_X: 0..1215
ABS_MT_POSITION_Y: 0..2687
```

If the Y range differs, the bottom swipe zone may be mapped elsewhere. Do not add swap/flip/scale flags until the actual ABS ranges and touch direction are captured.

## Rollback

D1T is a separate product lane. Rollback is to rebuild or flash the prior D1 image, the Coding-BR-in-Fox baseline image, or the backed-up `recovery_a` image.

Do not write both recovery slots during this candidate test.
