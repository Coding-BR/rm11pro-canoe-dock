# Coding-BR sm88XX-in-Fox Boot/ADB Log Analysis

Date: 2026-06-10

Target: REDMAGIC 11 Pro / NX809J / canoe / sm8850

Tested image:

```text
C:\temp\orangefox-codingbr-sm88xx-fox14-nx809j.img
```

Image SHA256:

```text
bac3d2ee0d85341e3729a0ac41822cbeb5266cbbd7ab2438d3fa50b5a7352820
```

Device-side test result:

```text
recovery_a write verified
booted past RedMagic logo
OrangeFox splash appeared
recovery ADB appeared
adb shell was already root
previous recovery_a backup was restored after capture
```

Raw evidence stays local-only:

```text
/home/richtofen/android/repositories/MainAssets/recovery-forensics/codingbr-nx809j-boot-adb-splash-20260610-204358
```

## Short Diagnosis

This is not behaving like the previous early boot failure. The recovery image boots far enough to start OrangeFox, bring up DRM graphics, draw the splash package, load vendor modules, and expose root recovery ADB.

The strongest blocker is the Android 16 decrypt/security runtime path under the Fox 14 recovery userspace:

- `/data` is not mounted.
- `keystore2` is stuck restarting.
- `vendor.keymint`, `vendor.keymint-qti`, `vendor.gatekeeper_default`, `vendor.qseecomd`, `vendor.weaver-service`, `vendor.health-default`, and secure element are restarting or failing.
- `recovery` waits repeatedly for `android.system.keystore2.IKeystoreService/default`.
- `hwservicemanager` and `servicemanager` cannot parse Android 16 VINTF manifest version `9.0` with the Fox 14 `libvintf@8.0` runtime.
- Vendor security binaries need a newer `libc++.so` symbol that recovery's default linker path resolves to the older system copy instead of the vendor copy.

So the current splash/ADB stop is most likely a decrypt/runtime hang, not the panel, framebuffer, or OrangeFox theme as the first blocker.

## Evidence Highlights

`recovery.log` confirms graphics and splash:

```text
Starting the UI...
width: 1216, height: 2688
setting DRM_FORMAT_XBGR8888 and GGL_PIXEL_FORMAT_RGBA_8888
Atomic Commit succeedUsing drm graphics.
Loading package: splash (/twres/splash.xml)
Switching packages (splash)
```

`recovery.log` confirms vendor modules were present:

```text
number of modules loaded by init: 326
found module to dedupe: zte_tpd.ko
found module to dedupe: panel_event_notifier.ko
found module to dedupe: kmparam.ko
Requested modules are loaded
```

`recovery.log` confirms `/data` did not mount before decrypt:

```text
Can't probe device /dev/block/sda12
Unable to mount '/data'
Actual block device: '/dev/block/sda12', current file system: 'f2fs'
prepdecrypt::File Based Encryption (FBE) is present.
prepdecrypt::crypto.ready=1
prepdecrypt::Script complete. Device ready for decryption.
```

`getprop.txt` shows the recovery process and ADB are alive, while the decrypt/security services are not stable:

```text
init.svc.adbd=running
init.svc.recovery=running
init.svc.keystore2=restarting
init.svc.vendor.gatekeeper_default=restarting
init.svc.vendor.keymint=restarting
init.svc.vendor.keymint-qti=restarting
init.svc.vendor.qseecomd=restarting
init.svc.vendor.weaver-service=restarting
```

`logcat-d.txt` shows the Fox 14 runtime cannot parse Android 16 VINTF manifest version `9.0`:

```text
Unrecognized manifest.version 9.0 (libvintf@8.0)
NULL VINTF MANIFEST!: device
NULL VINTF MANIFEST!: framework
Could not find android.hardware.security.keymint.IKeyMintDevice/default in the VINTF manifest.
```

`logcat-d.txt` shows vendor services failing before they can support keystore/decrypt:

```text
CANNOT LINK EXECUTABLE "/vendor/bin/hw/android.hardware.security.keymint-service-spu-qti":
cannot locate symbol "_ZNSt3__122__libcpp_verbose_abortEPKcz"

CANNOT LINK EXECUTABLE "/vendor/bin/qseecomd":
cannot locate symbol "_ZNSt3__122__libcpp_verbose_abortEPKcz"

CANNOT LINK EXECUTABLE "/vendor/bin/hw/android.hardware.gatekeeper-service-spu-qti":
cannot locate symbol "_ZNSt3__122__libcpp_verbose_abortEPKcz"
```

Local symbol check:

```text
vendor/lib64/libc++.so exports _ZNSt3__122__libcpp_verbose_abortEPKcz
system/lib64/libc++.so does not export _ZNSt3__122__libcpp_verbose_abortEPKcz
system/etc/ld.config.txt only searches /system/${LIB}
system/etc/init/hw/init.rc exports LD_LIBRARY_PATH=/system/lib64:/vendor/lib64/hw
```

That means vendor binaries are very likely resolving `libc++.so` from the older recovery system path instead of the Android 16 vendor path.

## Blocker Classification

| Area | Current read | Evidence | Priority |
| --- | --- | --- | --- |
| UI startup / graphics backend | Not primary | DRM atomic commit succeeds and splash loads | Low |
| framebuffer or DRM path | Not primary | `Using drm graphics`, panel binds, dimensions are correct | Low |
| touch/input blocking | Not primary yet | `synaptics_tcm_touch` appears as input event; noisy inputs are known but not first blocker | Medium later |
| decrypt wait | Primary suspect | `/data` mount fails; recovery waits for keystore2; keymint/gatekeeper/qseecomd fail | High |
| init/service hang | Primary suspect | decrypt/security services restart or fail to link | High |
| fstab/mount issue | Secondary | `/data` not mounted; `system_dlkm_oki` is nonexistent/noisy but likely not splash blocker | Medium |
| OrangeFox theme/resolution | Not primary | Theme scales and splash draws at 1216x2688 | Low |
| reboot-command handling | Unknown | No reboot UI path was captured because UI did not progress | Unknown |

## Candidate D Plan

Candidate D should be split into two boot-first sublanes. Do not merge this with the full decryption lane yet.

### Candidate D1: UI/ADB/Reboot Isolation, No Decrypt

Goal: prove the OrangeFox main UI and reboot path can run when the broken Android 16 decrypt/security stack is not allowed to hold startup hostage.

Scope:

- Keep the Coding-BR sm88XX platform identity, display, touch, module loading, and fstab baseline.
- Disable automatic decrypt/security service startup for the first isolation build.
- Do not import blobs.
- Do not change panel geometry.
- Do not change `zte_tpd` handling.
- Do not attempt `/data` decryption in this candidate.

Likely local Fox tree changes:

```text
/home/richtofen/android/repositories/MainAssets/fox_14.1/device/zte/sm88XX/BoardConfig.mk
/home/richtofen/android/repositories/MainAssets/fox_14.1/device/zte/sm88XX/recovery/root/init.recovery.qcom.rc
/home/richtofen/android/repositories/MainAssets/fox_14.1/device/zte/sm88XX/recovery/root/vendor/etc/init/*.rc
```

Candidate actions:

- Turn off or gate `TW_INCLUDE_CRYPTO`, `TW_INCLUDE_CRYPTO_FBE`, and `TW_INCLUDE_FBE_METADATA_DECRYPT` for this isolation build, or add a separate product makefile so the decrypt-disabled lane is explicit.
- Prevent `prepdecrypt.vendor` from auto-starting.
- Prevent these services from auto-starting in the isolation build:
  - `vendor.gatekeeper_default`
  - `vendor.keymint`
  - `vendor.keymint-qti`
  - `vendor.qseecomd`
  - `vendor.weaver-service`
  - `gto_secure_element_aidl_service`
  - `keystore2`, if recovery still starts it through imported system init.
- Keep `adbd`, `recovery`, `ueventd`, `servicemanager`, `hwservicemanager`, and display/touch/module paths intact.

Expected result:

```text
OrangeFox should pass splash into the normal UI.
ADB should remain root.
/data decrypt is expected not to work.
Reboot System should be tested only after UI is visible.
```

Rollback:

```text
git -C /home/richtofen/android/repositories/MainAssets/fox_14.1/device/zte/sm88XX diff
git -C /home/richtofen/android/repositories/MainAssets/fox_14.1/device/zte/sm88XX checkout -- <touched files>
```

### Candidate D2: Vendor Service Linker Fix, Crypto Still On

Goal: make the Android 16 vendor security services resolve their own Android 16 vendor libraries before the older Fox 14 system libraries.

Scope:

- Add service-local `LD_LIBRARY_PATH` for the vendor security/decrypt services.
- Prefer `/vendor/lib64` before `/system/lib64`.
- Do not copy new blobs into the dock repo.
- Do not replace the whole tree.

Candidate service environment:

```text
setenv LD_LIBRARY_PATH /vendor/lib64:/vendor/lib64/hw:/system/lib64:/system/lib
```

Apply only to relevant vendor services first:

```text
vendor.keymint-qti
vendor.keymint
vendor.gatekeeper_default
vendor.qseecomd
vendor.weaver-service
gto_secure_element_aidl_service
vendor.health-default
```

Expected result:

```text
The "CANNOT LINK EXECUTABLE ... __libcpp_verbose_abort" errors should disappear.
If VINTF version errors remain, keystore/decrypt may still fail.
```

Rollback:

```text
remove the added service-local setenv lines
rebuild recoveryimage
```

### Candidate D3: Android 16 VINTF/Decrypt Runtime Lane

Goal: make keystore/keymint/gatekeeper/qseecomd usable for FBE metadata decrypt.

Do this only after D1 proves UI/reboot or D2 proves service linking.

Options ranked:

1. Build on an Android 16-compatible TWRP/OrangeFox base, or port OrangeFox UI/features onto the Coding-BR working TWRP base.
2. Keep Fox 14 but provide a recovery-compatible VINTF framework/device manifest set that Fox 14 `libvintf@8.0` can parse.
3. Import newer Android 16 framework/runtime pieces into Fox 14.

Risk read:

- Option 1 is most maintainable.
- Option 2 may be a useful controlled recovery-only shim, but it is a compatibility hack.
- Option 3 is highest risk because framework libraries, servicemanager, hwservicemanager, keystore2, and linker behavior are tied together.

## Next Recommended Action

Build Candidate D1 first as a no-decrypt UI isolation image.

If D1 reaches the full OrangeFox UI and reboots normally, then the current blocker is confirmed as decrypt/security runtime. After that, D2 can attack the `LD_LIBRARY_PATH` issue and D3 can handle Android 16 VINTF/decryption properly.

Do not flash both slots. Continue using one-slot `recovery_a` tests with a verified rollback image.
