# Recovery Decryption And FBE

## Status

Recovery decryption is not proven for RM11 OrangeFox yet.

Current recovery lane:

- D1T3 proved basic OrangeFox UI/touch navigation in the no-decrypt lane.
- D2E booted with recovery ADB but crypto was disabled
  (`ro.orangefox.crypto_enabled=0`).
- D2F enabled crypto, reached OrangeFox animation, exposed recovery ADB, and
  stalled before menu with decrypt/security service restart loops.
- D2G has passed preflash marker proof only. It has not been flashed.

Kernel boot-hang notes are still highly relevant because they explain the Android 16 `/data` decryption chain.

## Android Boot Decryption Chain

Build #8 boot-hang lead:

```text
SCMI timeout
-> remoteproc ADSP/CDSP unavailable
-> smcinvoke/qseecom unavailable
-> keymint missing
-> vold missing
-> vdc cryptfs mountFstab never called
-> /data does not mount
```

Stock comparison:

- Stock starts `vendor.keymint`.
- Stock starts `vold`.
- Stock calls `vdc cryptfs mountFstab`.
- `/data` mounts through dm-crypt/FBE.

Custom failing path:

- `arm-scmi.1.auto` times out.
- `adsp-loader` loops with `fail to get rproc`.
- `keymint` and `vold` do not appear.
- `/data` remains unavailable.

## Recovery Decryption Test Requirements

When recovery UI boots, test in this order:

1. ADB shell available.
2. `recovery.fstab` maps metadata/userdata correctly.
3. `/metadata` mount behavior.
4. keymaster/keymint service availability in recovery environment.
5. vold/decryption path or recovery-specific decrypt support.
6. `/data` mount read-only first if possible.
7. Reboot to system.
8. Rollback recovery image.

Before any D2G flash, run:

```bash
<repo-root>/scripts/recovery/verify-d2g-preflash.sh
```

The script must prove image size, frozen SHA-256, D2G AVB fingerprint, D2G
default-property marker, all manual `sys.rm11.d2g.*` triggers, and the
crypto-enabled compile-lane expectation.

## Do Not Mix These

- Android boot FBE failure is not the same as recovery UI decrypt support.
- OrangeFox AVB boot failure is not proof that decrypt is broken.
- Touch failure in recovery is a separate gate from decrypt.

## What Helps Canoe Dock

Promote:

- recovery decrypt as a future checklist.
- Build #8 SCMI/FBE chain as kernel research.
- clear "not tested/not proven" status.

Do not promote:

- decryption success claims until recovery actually boots and mounts.
- private user data evidence.

## Source References

- `<local-build-root>/devices/RedMagic-11-Pro/output/notes-archive/rm11-notes-pre-categorize-20260608-215543.tar.gz`
- `<repo-root>/docs/13-custom-recovery-wip.md`
- `<repo-root>/docs/14-orangefox-wip.md`
