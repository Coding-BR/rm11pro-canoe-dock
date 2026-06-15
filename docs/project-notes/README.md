# RM11 Pro Project Notes

Device: RedMagic 11 Pro / REDMAGIC 11 Pro / NX809J.

Purpose: categorized notes merged into `rm11pro-canoe-dock` from the local RM11 device workspace, E-drive assets, and the experimental kernel/recovery worktree.

The old raw local note set was archived before cleanup but is intentionally not committed to this repo because it contained large dumps, browser metadata, binaries, and local-only paths.

```text
/home/richtofen/.android/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.tar.gz
/home/richtofen/.android/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.manifest.txt
SHA256: 23315e6f107b32ccb370b0f8d3dd0390c677d563b9f212693415e6a8a7c62489
```

## Active Categories

| Category | Note |
|---|---|
| Kernel building / patching | [01-kernel-building.md](01-kernel-building.md) |
| Custom recovery / OrangeFox | [02-custom-recovery.md](02-custom-recovery.md) |
| GSI / ROM building | [03-gsi-rom-building.md](03-gsi-rom-building.md) |
| ROM debloating | [04-rom-debloating.md](04-rom-debloating.md) |
| Rooting / Magisk init_boot | [05-rooting.md](05-rooting.md) |
| KernelSU / SuSFS | [06-kernelsu-susfs.md](06-kernelsu-susfs.md) |
| Recovery decryption / FBE | [07-recovery-decryption.md](07-recovery-decryption.md) |
| Modules / vendor_dlkm / .ko testing | [08-modules-vendor-dlkm.md](08-modules-vendor-dlkm.md) |
| APK customization | [09-apk-customization.md](09-apk-customization.md) |
| ROM deodexing | [10-rom-deodexing.md](10-rom-deodexing.md) |
| Local assets and repo map | [11-assets-and-repo-map.md](11-assets-and-repo-map.md) |
| Next actions | [12-next-actions.md](12-next-actions.md) |
| Kernel lab provenance | [13-kernel-lab-provenance.md](13-kernel-lab-provenance.md) |
| Starred repo sync / build map | [14-starred-repo-sync-and-build-map.md](14-starred-repo-sync-and-build-map.md) |
| Droidspace / containers | [15-droidspace-container-lane.md](15-droidspace-container-lane.md) |

## Canoe Dock Merge Rule

`rm11pro-canoe-dock` should stay the public release/evidence dock. It should not absorb giant raw reverse-engineering dumps or private identity partitions.

Promote only material that has:

- Exact RM11 Pro / NX809J scope.
- Firmware/build baseline.
- Artifact hash.
- Boot/result evidence.
- Rollback path.
- Clear warning if WIP.

Everything else stays local in these project notes or in archived evidence.

OrangeFox recovery has a dedicated evidence folder at [../orangefox-port/README.md](../orangefox-port/README.md). Raw recovery images, logs, and headers stay local under `/home/richtofen/.android/repositories/MainAssets/recovery-forensics`.

## Source Material Used

- `/home/richtofen/.android/devices/RedMagic-11-Pro/notes` cleaned local notes.
- `/mnt/e/Android/RM-11-Pro/staging-notes`.
- `/mnt/e/Android/RM-11-Pro/BOOT`, `RECOVERY`, `KERNELS`, `MODULES`, and `Tools`.
- `/home/richtofen/.android/repositories/rm11pro-canoe-dock`.
- `/home/richtofen/.android/repositories/rm11pro-canoe-dock/recovery/device/zte/sm88XX`.
- Former local kernel checkout `rm11-recovery-next-from-myfork-main`, reviewed before cleanup and then deleted.
- Upstream kernel source lineage: `https://github.com/Coding-BR/android_kernel_nubia_sm8850_qwjujube`.

## Current Repository Reality

- `rm11pro-canoe-dock` is the active public dock repo under `/home/richtofen/.android/repositories`.
- Helper/tool checkouts may also live under `/home/richtofen/.android/repositories`; keep them local unless a specific artifact is promoted into the dock.
- Local-only heavy assets live under `/home/richtofen/.android/repositories/MainAssets`.
- Raw recovery forensics live under `/home/richtofen/.android/repositories/MainAssets/recovery-forensics`.
- The broken local kernel checkout was deleted after the useful notes were summarized.
- Re-clone `https://github.com/Coding-BR/android_kernel_nubia_sm8850_qwjujube` when kernel-source work resumes.

Primary GitHub star lists for project research:

- `RM11Pro-Canoe-Dock`: main RM11 Pro root/kernel/recovery/GSI/module lane.
- `RM11Pro-Canoe-Dock-Droidspace`: RM11 Pro OS-container/Droidspaces lane.
