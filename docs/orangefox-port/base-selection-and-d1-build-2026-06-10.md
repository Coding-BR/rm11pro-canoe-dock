# RM11 Pro OrangeFox Base Selection and Candidate D1 Build

Date: 2026-06-10

Target:

- Device: REDMAGIC 11 Pro / NX809J
- Product/platform evidence: canoe / sm8850
- Recovery lane under test: Coding-BR sm88XX device tree inside the local Fox 14.1 source tree
- Current local source tree: `/home/richtofen/android/repositories/MainAssets/fox_14.1`

## Question

Should this work move from the current Fox 14.1 base to a newer OrangeFox or TWRP base before continuing?

## Short Answer

No. Keep the current Fox 14.1 base for the next boot tests.

Reason: the Coding-BR-in-Fox lane already boots far enough on NX809J to show OrangeFox splash, initialize DRM graphics, load vendor modules, and expose root recovery ADB. I did not find a clearly newer OrangeFox Android 15/16 branch, and the visible TWRP public branches/manifests top out around Android 14/14.1. Migrating now would trade a known bootable lane for an unproven source-base migration without evidence that Android 16 decryption would be fixed by the move.

## Upstream Branch Check

Observed current local Fox tree:

- Manifest source: `https://github.com/nebrassy/platform_manifest_twrp_aosp.git`
- Manifest branch: `twrp-14`
- Default platform tag: `android-14.0.0_r67`
- Recovery source: nebrassy `bootable/recovery`, `android-14`
- Vendor recovery source: nebrassy `vendor/twrp`, `android-14`

OrangeFox references checked:

- `https://gitlab.com/OrangeFox/sync.git`
- `https://gitlab.com/OrangeFox/bootable/Recovery.git`
- `https://wiki.orangefox.tech/en/dev/building`

Result:

- OrangeFox sync repo exposes `master`.
- OrangeFox recovery repo exposes historical Fox branches through `fox_14.1`.
- I did not find an official `fox_15` or `fox_16` branch.
- OrangeFox build docs still point newer-device work at `fox_14.1` when 14.x is required, with decryption treated as a device-tree/runtime problem.

TWRP references checked:

- `https://github.com/TeamWin/android_bootable_recovery`
- `https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp`

Result:

- Public TWRP recovery/manifests checked top out at Android 14/14.1 style branches.
- I did not find a public Android 15/16 TWRP base that is clearly ready to solve NX809J Android 16 FBE/keymint/gatekeeper/qsee/weaver runtime issues.

## Current Fox 14.1 Pros

- Already builds in the local WSL tree.
- Coding-BR sm88XX lane already boots on real NX809J to OrangeFox splash.
- Recovery ADB appears and runs as root.
- DRM/display path is alive enough to get past the RedMagic logo.
- Image layout matches the device recovery partition format:
  - Android boot image header v4
  - kernel size 0
  - ramdisk-only recovery partition image
  - 104857600 bytes
- This lane is reversible and can be tested one recovery slot at a time.

## Current Fox 14.1 Cons

- Userspace base is Android 14-era, while the device is currently Android 16-class.
- Existing logs point at Android 16 decrypt/security runtime breakage:
  - `libvintf@8.0` does not recognize manifest version 9.0.
  - Vendor security services fail or restart.
  - Recovery waits for `android.system.keystore2.IKeystoreService/default`.
  - Vendor `libc++.so` has `__libcpp_verbose_abort`, but system `libc++.so` in recovery does not.
- `/data` does not mount/decrypt in the current bootable lane.
- Decryption is not fixed by Candidate D1; D1 deliberately disables that path for UI isolation.

## Migration Risks Right Now

- Losing the only real-device-proven OrangeFox splash plus root ADB lane.
- Reintroducing boot-logo hangs from product/platform/build conditionals.
- Needing to redo BoardConfig, recovery ramdisk layout, init overlays, sepolicy, module loading, fstab, dynamic partition handling, and AVB/image sizing all at once.
- No confirmed public Fox/TWRP Android 15/16 base was found to justify that risk.

## What A Future Migration Would Need

If a real newer base becomes available, port it as a separate lane:

1. Fresh source checkout, not overwrite the current `fox_14.1` tree.
2. Import the Coding-BR sm88XX/NX809J device tree incrementally.
3. Preserve proven partition/image facts:
   - `BOARD_BOOT_HEADER_VERSION := 4`
   - `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`
   - `BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600`
   - ramdisk-only recovery image
4. Preserve known identity:
   - NX809J
   - REDMAGIC 11 Pro
   - canoe
   - sm8850
5. Reapply display/touch/module handling only after boot/splash/ADB is confirmed.
6. Treat decrypt as a later lane that needs linker/VINTF/security-service work, not as the first boot test.

## Candidate D1 Goal

D1 is a no-decrypt UI isolation candidate.

Intent:

- Keep the Coding-BR-in-Fox bootable base.
- Do not fix decryption yet.
- Prevent the Android 16 decrypt/security stack from starting far enough to trap recovery in keystore/keymint/gatekeeper/qsee/weaver wait loops.
- Keep recovery image layout unchanged.
- Keep `/data` decrypt expected-broken.
- Test whether OrangeFox can reach a usable UI and normal reboot path when decrypt runtime is not the blocker.

## Candidate D1 Source Changes

Text-only source lane changes were made in the local Fox tree, not in the dock repo source tree:

- Added product: `orangefox_NX809J_codingbr_d1`
- Added D1 lunch choices.
- For D1 only, added `TARGET_RECOVERY_DEVICE_DIRS := device/zte/sm88XX device/zte/sm88XX/d1`.
- For D1 only, disabled crypto/decrypt flags:
  - `BOARD_USES_QCOM_FBE_DECRYPTION`
  - `TW_INCLUDE_CRYPTO`
  - `TW_INCLUDE_CRYPTO_FBE`
  - `TW_INCLUDE_FBE_METADATA_DECRYPT`
  - `TW_USE_FSCRYPT_POLICY`
  - `TW_INCLUDE_OMAPI`
- Added D1 ramdisk init overlays that keep these services present but disabled:
  - `keystore2`
  - `se_omapi`
  - `vendor.gatekeeper_default`
  - `vendor.health-default`
  - `vendor.charger`
  - `gto_secure_element_aidl_service`
  - `vendor.keymint-qti`
  - `vendor.keymint`
  - `vendor.weaver-service`
  - `vendor.qseecomd`
- Added a D1 `init.recovery.qcom.rc` overlay that avoids the decrypt/service start triggers while preserving USB, firmware mount, brightness, input unbind, and basic recovery setup.

Exact diff:

- `docs/orangefox-port/candidate-diffs/candidate-d1-nodecrypt-ui-isolation.diff`

Touched-file list:

- `docs/orangefox-port/candidate-diffs/candidate-d1-nodecrypt-ui-isolation.files.txt`

Check summary:

- `docs/orangefox-port/candidate-diffs/candidate-d1-nodecrypt-ui-isolation.check.txt`

## Build Command Used

```bash
cd /home/richtofen/android/repositories/MainAssets/fox_14.1

mkdir -p out/target/product/sm88XX/recovery/root
rm -rf out/target/product/sm88XX/recovery/root/twres
cp -a out/recovery/root/twres out/target/product/sm88XX/recovery/root/

source build/envsetup.sh
export TARGET_PRODUCT=orangefox_NX809J_codingbr_d1
export TARGET_RELEASE=ap2a
export TARGET_BUILD_VARIANT=eng
mka recoveryimage
```

The `twres` copy is a build-output workaround only. The Fox Soong theme hook generated `twres` under top-level `out/recovery/root/twres`, while the recovery packaging step expected it under the product recovery root.

## Build Result

Result: pass.

Output images:

- `/home/richtofen/android/repositories/MainAssets/fox_14.1/out/target/product/sm88XX/recovery.img`
- `/home/richtofen/android/repositories/MainAssets/fox_14.1/out/target/product/sm88XX/OrangeFox-R12.0-Unofficial-NX809J.img`

Stable local evidence copy:

- `/home/richtofen/android/repositories/MainAssets/recovery-forensics/d1-nodecrypt-ui-isolation/OrangeFox-R12.0-Unofficial-NX809J-d1-nodecrypt-ui-isolation.img`
- `/home/richtofen/android/repositories/MainAssets/recovery-forensics/d1-nodecrypt-ui-isolation/recovery-d1-nodecrypt-ui-isolation.img`

Image facts:

- `recovery.img` size: `104857600` bytes
- `OrangeFox-R12.0-Unofficial-NX809J.img` size: `104857600` bytes
- SHA256: `825e5fe8b4398e7b3484fb010855bf5fbdf53eb46e1f50f48976189d6e5beb42`
- Header: Android boot image v4
- Kernel size: `0`
- Ramdisk size: `40060393`
- OS version: `99.87.36`
- OS patch level: `2099-12`

OrangeFox also produced a zip as part of its normal post-build step:

- `/home/richtofen/android/repositories/MainAssets/fox_14.1/out/target/product/sm88XX/OrangeFox-R12.0-Unofficial-NX809J.zip`
- Zip size: `58632274` bytes
- Zip SHA256: `e0a3eae32c802c2d7b1fb7e60b4e52ac8b3c5ee9214e31c978d5eb6524c4605e`

That zip is not part of the D1 recovery-slot test plan.

## Verification

- D1 touched source whitespace check: pass.
- Build result: pass.
- Generated recovery image remains exactly `104857600` bytes.
- Generated OrangeFox image remains exactly `104857600` bytes.
- Generated ramdisk root contains the D1 disabled service overrides.
- Residual start-trigger grep found no active `start keymint`, `start qsee`, `start gatekeeper`, `start weaver`, `start prepdecrypt`, or `start keystore2` style trigger in the generated recovery root.

## Recommendation

Do not migrate bases now.

Next step should be a cautious one-slot D1 recovery test on `recovery_a` only, after confirming current backup/restore paths. Expected outcome is not decrypt. The question for D1 is narrower:

- Does OrangeFox reach full UI?
- Does recovery ADB stay usable?
- Does reboot work normally?
- Does it avoid the previous keystore/security-runtime wait loop?

If D1 reaches usable UI, the next lane should be D2: linker/runtime repair for Android 16 security services, still without changing recovery image layout.
