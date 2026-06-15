# Starred Repo Sync And Build Map

Scan date: 2026-06-15

Source list:

```text
https://github.com/stars/Fractal-Echo/lists/rm11pro-canoe-dock
```

GitHub showed 22 repositories in `RM11Pro-Canoe-Dock`.

## Priority Order

1. Recovery proof and rollback safety.
2. Kernel/root package provenance.
3. APK/module builds that improve device control or evidence capture.
4. ROM/OTA extraction tooling.
5. Droidspace/Linux-container/Windows-experience stack.

Do not let APK hoarding or emulator experiments jump ahead of recovery safety.

## Recovery And ROM Lane

High priority:

- `Fractal-Echo/android_device_zte_sm88XX-twrp`
- `Fractal-Echo/RM11Pro-SM8850-LineageOS`
- `Fractal-Echo/rm11pro-canoe-dock`

Local state:

- `/home/richtofen/.android/repositories/MainAssets/references/codingbr_zte_sm88xx_twrp`
  tracks `Coding-BR/android_device_zte_sm88XX-twrp`, not the `Fractal-Echo`
  fork. Fetch-only check shows it is behind upstream by 22 commits and picked up
  new workflow tags.
- D2G OrangeFox marker proof is now local and reproducible through
  `scripts/recovery/verify-d2g-preflash.sh`.
- The working TWRP reference image is not present at
  `/home/richtofen/.android/repositories/MainAssets/references/TWRP-3.7.1-16devreverse.img`.

Next actions:

- Do not flash D2G until the one-slot test is intentional.
- Place the working TWRP image at the expected `MainAssets/references/` path.
- Use `scripts/recovery/unpack-android-boot-lz4.sh` and
  `scripts/recovery/compare-recovery-ramdisks.sh` to compare TWRP against
  OrangeFox before copying any Wi-Fi/decrypt files.
- Decide whether the local reference should track the Coding-BR upstream or the
  `Fractal-Echo/android_device_zte_sm88XX-twrp` fork before merging the 22
  incoming commits.

## Kernel And Root Lane

High priority:

- `Fractal-Echo/android_kernel_nubia_sm8850_jujube`
- `Fractal-Echo/RM11Plus_KernelSU_SUSFS`
- `Fractal-Echo/KernelSU-Next`
- `Fractal-Echo/susfs4ksu-module`
- `Fractal-Echo/Magisk`
- `Fractal-Echo/ZygiskNext`
- `Fractal-Echo/ABK`

Local state:

- `MainAssets/kernels` has the guarded RM11 AnyKernel3 package contents and the
  older OP15/OOS16 source package.
- The known-good guarded package hash remains:

```text
7CAC8A90FD065FD2F31F8E1938ECE8F5BEA061CBD8213A03E44B86BA50EA1B4A
```

Next actions:

- Keep kernel zips, boot images, and module payloads in `MainAssets`, not in the
  public dock.
- Promote only README/provenance/hash/rollback docs into the dock.
- Reconcile the dock `releases/anykernel/...` deletion before any release
  cleanup. The public docs appear to have been copied under local
  `canoe-dock-setup-files/`, but that folder is now intentionally ignored as a
  payload staging area.

## APK And Module Lane

Useful repos:

- `Fractal-Echo/Redmagic-Control-Center`
- `Fractal-Echo/NubiaToolkit`
- `Fractal-Echo/VirtualAP`
- `Fractal-Echo/nx809j-ir-port`
- `Fractal-Echo/LSPosed`
- `Fractal-Echo/LSFG-Android`

Local state:

- `Redmagic-Control-Center` has a debug APK at
  `/home/richtofen/.android/repositories/Redmagic-Control-Center/app/build/outputs/apk/debug/app-debug.apk`.
  Its release signing path uses environment variables.
- `NubiaToolkit` has a debug APK at
  `/home/richtofen/.android/repositories/NubiaToolkit/app/build/outputs/apk/debug/app-debug.apk`.
  It also has a local `release-key.jks` and hardcoded release signing fields in
  Gradle. Treat that as cleanup-required before any public release.
- `MainAssets/APK` already holds Winlator, GameHub, KernelFlasher,
  KernelSU-Next Manager, Magisk, Redmagic Control Center, NubiaToolkit, and
  other APKs.

Next actions:

- Keep built APKs in `MainAssets/APK`.
- Add hashes/provenance to the dock only after each APK source, version, and
  signing mode are clear.
- Fix NubiaToolkit signing before treating any release APK as publishable.

## Extraction And Build Tooling

Useful repos:

- `Fractal-Echo/Mio-Kitchen-Source`
- `Fractal-Echo/otaripper`
- local `payload-dumper/payload-dumper-go`
- local `reversa`

Local state:

- `Mio-Kitchen-Source` is behind upstream by 8 commits after fetch-only update.
  It is dirty with `bin/setting.ini`, unpacked `boot.img` / `boot/`, and many
  `bin/module` plus `bin/temp` payloads.
- `reversa` is behind upstream by 1 commit after fetch-only update. Its local
  changes are executable bit changes and `package-lock.json` version/engine
  metadata.
- `payload-dumper-go` is clean relative to origin but has an untracked local
  binary named `payload-dumper-go`.

Next actions:

- Do not pull Mio until its unpacked boot artifacts are moved or intentionally
  kept local.
- Use `otaripper` or `payload-dumper-go` for OTA partition extraction, then move
  resulting images to `MainAssets`, not the dock.
- Use `reversa` for summarizing legacy APK/tool behavior only after its one
  upstream commit is reviewed.

## Droidspace / Linux / Windows Experience Lane

Useful repos:

- `Fractal-Echo/termux-app`
- `Fractal-Echo/termux-x11`
- `Fractal-Echo/Winlator-Ludashi-emulador-windows-acompanhar`
- `Fractal-Echo/VirtualAP`
- `Fractal-Echo/ELFLoaderARM`
- `Fractal-Echo/LSFG-Android`

Recommended order after recovery is stable:

1. Termux base plus Termux:X11.
2. Input/display/audio proof on RM11.
3. Winlator/Box64 path for Windows apps.
4. VirtualAP only after networking rollback is clear.
5. ELFLoaderARM/LSFG as experimental acceleration or compatibility lanes.

Do not mix this with recovery flashing logs. It should become its own evidence
folder once recovery is no longer the active blocker.

## Local Dirty Repo Summary

```text
Mio-Kitchen-Source: behind 8, dirty with unpacked boot/tool payloads.
reversa: behind 1, dirty with chmod/package-lock metadata.
NubiaToolkit: dirty gradlew chmod; local signing key present.
Redmagic-Control-Center: dirty gradlew chmod.
gbl-chainload: dirty submodule/worktree marker under edk2.
OrangeFox_sync: dirty deleted legacy files plus fox_14.1_manifest.sav.
rm11pro-canoe-dock: current docs/scripts edits plus pre-existing releases deletions.
```

## Public Dock Rule

The dock should track:

- scripts,
- manifests,
- hashes,
- reproducible build notes,
- rollback instructions,
- public-safe summaries.

The dock should not track:

- APKs,
- AnyKernel zips,
- recovery/boot/vendor_boot images,
- super images,
- stock dumps,
- private logs,
- signing keys,
- extracted proprietary payloads.
