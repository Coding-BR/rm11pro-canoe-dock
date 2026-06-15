# D2N Recovery Baseline

Date: 2026-06-15

Device: REDMAGIC 11 Pro / RM11 Pro / NX809J / canoe.

This note promotes D2N from probe candidate to the current OrangeFox recovery
baseline for the local RM11 lab. Raw images and logs stay local under
`/home/richtofen/.android/repositories/MainAssets/recovery-forensics`.

## Verdict

D2N is the current winning recovery build.

Observed result:

- One-slot flash to `recovery_a` completed.
- `recovery_a` readback matched the frozen D2N image before and after reboot.
- OrangeFox booted to recovery.
- Tap, scroll, and navigation work.
- Crypto lane is enabled.
- `/data` and `/sdcard` mount decrypted.
- Gatekeeper now auto-starts after listener registration.
- The UI lock/timeout defaults apply and persist after the helper exits.

## Frozen Artifacts

Image:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-auto-decrypt-ui-gatekeeper-polish/OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.img
size: 104857600
sha256: a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0
```

Zip:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-auto-decrypt-ui-gatekeeper-polish/OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.zip
size: 64548932
sha256: 5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab
```

AVB fingerprint:

```text
REDMAGIC/orangefox_NX809J_codingbr_d2n/sm88XX:99.87.36/AP2A.240905.003/eng.richto.20260615.023045:eng/test-keys
```

## Verifier

Local helper:

```bash
scripts/recovery/verify-d2n-preflash.sh
```

Passing log:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-auto-decrypt-ui-gatekeeper-polish/logs/verify-d2n-preflash-rerun.log
```

Verifier scope:

- Checks the frozen image size and SHA-256.
- Checks AVB fingerprint contains `orangefox_NX809J_codingbr_d2n`.
- Checks the D2N product makefile, lunch choices, and BoardConfig overlay stack.
- Confirms D2N stays in the crypto-enabled build lane.
- Confirms the D1T3 touch marker remains present.
- Confirms no Wi-Fi lane is merged.
- Confirms D2N decrypt/service semantics in source and unpacked ramdisk.
- Confirms D2N UI defaults service and script exist in source and unpacked ramdisk.
- Confirms no D2M/D2H/D2J/D2K/D2L service triggers or stale decrypt markers remain in init/property text.
- Allows the inherited D2M scoped libc++ payload only when its SHA matches the known D2M/D2N libc++ hash.

## Live Evidence

Result summary:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-live-probe-20260615-024231/result-summary.txt
```

Flash log:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-live-probe-20260615-024231/00-flash/flash-d2n.log
```

Postboot capture:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-live-probe-20260615-024231/01-postboot/postboot-summary.txt
```

Delayed capture:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-live-probe-20260615-024231/02-delayed-status/delayed-summary.txt
```

Post-reboot partition readback:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2n-live-probe-20260615-024231/03-readback-after-boot/recovery_a.sha256sum
```

Key live props:

```text
ro.rm11.decrypt_candidate_d2n=d2n-auto-decrypt-ui-gatekeeper-polish
ro.orangefox.crypto_enabled=1
prepdecrypt.setpatch=true
twrp.decrypt.done=true
twrp.all.users.decrypted=true
twrp.user.0.decrypt=1
init.svc.vendor.qseecomd=running
init.svc.vendor.keymint=running
init.svc.vendor.gatekeeper_default=running
init.svc.keystore2=running
vendor.sys.listeners.registered=true
vendor.gatekeeper.is_security_level_spu=0
init.svc.rm11-d2n-ui-defaults=stopped
tw_screen_timeout_secs=0
tw_no_screen_timeout=1
tw_screen_timeout_temp=0
lock_btn=1
lock_action=0
```

Mount proof:

```text
/dev/block/dm-7 on /data type f2fs
/dev/block/dm-7 on /sdcard type f2fs
```

## D2N Delta

D2N builds on the live-proven D2M decrypt lane:

- qseecomd autostarts with the D2K full compat library path.
- onekeymint autostarts.
- keystore2 uses the TWRP binary path and scoped libc++ path.
- boot HAL uses the scoped libc++ path.
- strongbox keymint-qti, weaver, and secure element stay disabled/oneshot side lanes.

D2N adds:

- `ro.rm11.decrypt_candidate_d2n=d2n-auto-decrypt-ui-gatekeeper-polish`
- `vendor.gatekeeper_default` start on `vendor.sys.listeners.registered=true`
- `rm11-d2n-ui-defaults` recovery helper
- runtime OrangeFox settings:
  - `tw_screen_timeout_secs=0`
  - `tw_no_screen_timeout=1`
  - `tw_screen_timeout_temp=0`
  - `lock_btn=1`
  - `lock_action=0`

## Still Unproven

D2N is a recovery baseline, not a full release certification.

Still needs separate tests:

- MTP.
- fastbootd.
- backups and restores.
- ZIP installs.
- image flashing from UI.
- wipes and format paths.
- USB OTG.
- reboot-menu behavior.
- A/B slot workflow beyond the one-slot `recovery_a` probe.
- Wi-Fi. Wi-Fi is intentionally a separate future lane.

## Rollback

Known rollback candidates remain local:

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/d2m-auto-decrypt-libcxx-keystore/OrangeFox-R12.0-Unofficial-NX809J-d2m-auto-decrypt-libcxx-keystore.img
sha256: 7a08ab7aaa14d839b5642507a4608710900d054a7af9724b35a385e2d13dac3a
```

```text
/home/richtofen/.android/repositories/MainAssets/recovery-forensics/TWRP-3.7.1-16devreverse.img
sha256: dfeeb53817cde67ce3b5a93e5087d8395c4b4f1ca44aac793ad7aa704df34a10
```

Use one-slot recovery tests first. Do not write both recovery slots without a
fresh explicit test plan.
