# Local OrangeFox Build Lane

Date: 2026-06-15

Goal: make RM11 Pro / NX809J OrangeFox builds reproducible by a local builder or
fork owner without giving public CI access to a private machine.

## Inputs

- Public device-tree snapshot: `recovery/device/zte/sm88XX`
- Recovery patch sets: `recovery/patches/fox_14.1`
- Recovery prebuilt policy and manifests: `recovery/prebuilts`,
  `recovery/manifests`
- Local builder's OrangeFox/TWRP tree
- Local builder's legally available proprietary prebuilts

## Script

```bash
scripts/local-build/build-orangefox-nx809j-local.sh --env scripts/local-build/env-orangefox-nx809j.local
```

The script prepares the RM11 device tree inside the local OrangeFox checkout,
runs the configured lunch target, builds the configured goals, and records output
hashes under `out/local-orangefox-nx809j`.

## D2N Baseline

D2N remains the current recovery baseline. Its tracked public records are:

- `docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md`
- `recovery/manifests/d2n-baseline.sha256`
- `scripts/recovery/verify-d2n-preflash.sh`

The D2N preflash verifier is intentionally local because it checks private lab
artifact paths and unpacked images.

## CI Boundary

Public Actions only verify the repo. They do not build OrangeFox, sync Android
source, touch a connected phone, or run on the maintainer's machine.
