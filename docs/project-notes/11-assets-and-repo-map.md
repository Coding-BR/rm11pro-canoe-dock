# Assets And Repo Map

## WSL Device Project

```text
<local-build-root>/devices/RedMagic-11-Pro
```

Important subfolders:

- `backups/`
- `kernels/`
- `logs/`
- `modules/`
- `notes/`
- `output/`
- `platform-tools/`
- `repositories/`

## E Drive RM11 Assets

```text
/mnt/e/Android/RM-11-Pro
```

Important subfolders:

- `BOOT/`
- `RECOVERY/`
- `KERNELS/`
- `MODULES/`
- `Tools/`
- `staging-notes/`
- `usb_driver/`

High-value assets found:

- `BOOT/init_boot_a.img`
- `BOOT/magisk_patched_rm11_init_boot_a.img`
- `BOOT/BACKUP-ROOTED-2026-06-07/`
- `RECOVERY/BACKUP-BEFORE-ORANGEFOX-2026-06-07/`
- `BOOT/XX-Dev-Rom/`
- `BOOT/GSI/`
- `MODULES/v34.3-Integrity-Box-04-04-2026/`
- `staging-notes/README_X1_FRESH_START.md`
- `staging-notes/ROM_MAKING_USEFUL_KEEPERS.md`

## Repositories

Local repository root:

```text
<local-build-root>/repositories
```

Primary GitHub star lists:

- [RM11Pro-Canoe-Dock](https://github.com/stars/Fractal-Echo/lists/rm11pro-canoe-dock): main RM11 Pro root, kernel, recovery, GSI/ROM, and module lane.
- [RM11Pro-Canoe-Dock-Droidspace](https://github.com/stars/Fractal-Echo/lists/rm11pro-canoe-dock-droidspace): RM11 Pro OS-container/Droidspaces lane.

### rm11pro-canoe-dock

```text
<repo-root>
```

Purpose:

- Public RM11 Pro dock.
- Unlock/root/KSU/GSI/recovery WIP/release notes.
- Should stay curated and evidence-oriented.

Git state observed:

```text
branch: main
remote: https://github.com/Fractal-Echo/rm11pro-canoe-dock.git
status: staged consolidation changes; raw forensics moved to Main Assets
```

### Deleted kernel checkout

The former `rm11-recovery-next-from-myfork-main` folder was deleted during cleanup.

Reason:

- useful notes were summarized into the dock.
- the checkout had broken Git worktree metadata.
- upstream can be re-cloned when the kernel/KSU/module lane needs source again.

Upstream:

```text
https://github.com/Coding-BR/android_kernel_nubia_sm8850_qwjujube
```

### rm11pro-orangefox-recovery archived source

```text
<repo-root>/recovery/device/zte/sm88XX
```

Purpose:

- Forked OrangeFox/RM10 starting point ported toward NX809J/RM11.

Git state observed:

```text
branch: codex/nx809j-rm11pro-port
remote origin: https://github.com/Fractal-Echo/rm11pro-orangefox-recovery.git
remote upstream: https://github.com/plompomg/rm10pro-orangefox-recovery.git
status: local modifications and untracked docs/keys/prebuilt/android16/
```

## Canoe Dock Folder Mapping

| Local category | Canoe dock target |
|---|---|
| Kernel/KSU validated package | `docs/09-anykernel3-gki.md`, `docs/10-kernelsu-next-susfs.md`, `releases/anykernel/` |
| Magisk/root | `docs/08-root-magisk-init-boot.md`, `docs/11-magisk-to-kernelsu.md` |
| GSI/ROM | `docs/12-gsi-rom-flow.md`, `releases/gsi-roms/` |
| OrangeFox/recovery | `docs/13-custom-recovery-wip.md`, `docs/14-orangefox-wip.md`, `releases/recovery/` |
| Modules/tools | `docs/15-modules-and-tools.md`, `releases/modules/` |
| Troubleshooting | `docs/16-troubleshooting.md` |
| Public XDA-style guide | `docs/xda-redmagic-11-pro-access-guide.md` |

## Do Not Commit To Public Repo

Do not commit:

- private identity/calibration partitions.
- raw `super.img`.
- random stock firmware blobs.
- giant reverse-engineering dumps.
- personal patched boot/init_boot images unless deliberately releasing and documented.
- raw recovery images inside the dock repo; they now live under `<local-build-root>/recovery-forensics`.
