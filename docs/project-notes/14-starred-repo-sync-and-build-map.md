# Starred Repo Sync And Build Map

Scan date: 2026-06-15

Source list:

```text
https://github.com/stars/Fractal-Echo/lists/rm11pro-canoe-dock
```

GitHub API refresh also found the wider `Fractal-Echo` starred set, including
the Droidspaces support stack that was not captured in the first narrow pass.

## Priority Order

1. Recovery proof and rollback safety.
2. Droidspace/Linux-container base proof.
3. Kernel/root package provenance.
4. APK/module builds that improve device control or evidence capture.
5. ROM/OTA extraction tooling.
6. Windows-experience stack through Winlator/Box64 after Linux proof.

Do not let APK hoarding or emulator experiments jump ahead of recovery safety.

## Recovery And ROM Lane

High priority:

- `Fractal-Echo/android_device_zte_sm88XX-twrp`
- `Fractal-Echo/RM11Pro-SM8850-LineageOS`
- `Fractal-Echo/rm11pro-canoe-dock`

Local state:

- `<local-build-root>/references/codingbr_zte_sm88xx_twrp`
  tracks `Coding-BR/android_device_zte_sm88XX-twrp`, not the `Fractal-Echo`
  fork. Fetch-only check shows it is behind upstream by 22 commits and picked up
  new workflow tags.
- D2N is now the current OrangeFox recovery baseline. Its frozen image hash is
  `a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0`.
- The working TWRP reference image is not present at
  `<local-build-root>/references/TWRP-3.7.1-16devreverse.img`.

Next actions:

- Keep D2N as the recovery baseline while operation-specific tests remain open.
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
  `<local-build-root>/repositories/Redmagic-Control-Center/app/build/outputs/apk/debug/app-debug.apk`.
  Its release signing path uses environment variables.
- `NubiaToolkit` has a debug APK at
  `<local-build-root>/repositories/NubiaToolkit/app/build/outputs/apk/debug/app-debug.apk`.
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

- `Fractal-Echo/Droidspaces-OSS`
- `Fractal-Echo/Droidspaces-kernel`
- `Fractal-Echo/Droidspaces-rootfs-KDE-builder`
- `Fractal-Echo/Droidspaces_Kernel_patch`
- `Fractal-Echo/busybox-droidspaces`
- `Fractal-Echo/toybox-droidspaces`
- `Fractal-Echo/socketd`
- `Fractal-Echo/webui`
- `Fractal-Echo/linuxcontainers-mirror`
- `Fractal-Echo/mesa-for-android-container-rm11pro`
- `Fractal-Echo/termux-app`
- `Fractal-Echo/termux-x11`
- `Fractal-Echo/Winlator-Ludashi-emulador-windows-acompanhar`
- `Fractal-Echo/VirtualAP`
- `Fractal-Echo/ELFLoaderARM`
- `Fractal-Echo/LSFG-Android`

Local state:

- Core Droidspace repos were cloned/fetched into
  `<local-build-root>/repositories/droidspace-core` through
  `scripts/repo/sync-droidspace-core.sh`.
- Heavy repos were deliberately deferred:
  - `Droidspaces-kernel`
  - `mesa-for-android-container-rm11pro`
  - `Winlator-Ludashi-emulador-windows-acompanhar`
  - `droidspaces-recovery-hack-example`
- Droidspaces Android debug APK was built and promoted locally:

```text
<local-build-root>/APK/Droidspaces-OSS-v6.3.0-debug.apk
size: 22524969
sha256: 575260b1f3a31ed0c0a05e90d52b8d461306fbd7381addeb153d68b4038817a6
package: com.droidspaces.app
versionName: 6.3.0
versionCode: 6300
```

Recommended order after D2N:

1. Boot Android and capture kernel/root/SELinux baseline.
2. Install Droidspaces debug APK only after the baseline capture.
3. Run Droidspaces checker before importing rootfs payloads.
4. Minimal rootfs first.
5. Termux:X11 display proof.
6. Audio proof.
7. GPU proof.
8. KDE rootfs.
9. Winlator/Box64 path for Windows apps.
10. VirtualAP only after networking rollback is clear.
11. ELFLoaderARM/LSFG as experimental acceleration or compatibility lanes.

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
rm11pro-canoe-dock: pre-existing releases deletions plus local verifier drafts.
droidspace-core/*: clean immediately after clone/fetch; build output exists in
  Droidspaces-OSS after debug APK build.
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
