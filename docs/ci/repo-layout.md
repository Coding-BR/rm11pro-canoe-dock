# Repository Layout

Date: 2026-06-15

This repo is the public RM11 Pro / NX809J / canoe dock. It keeps source,
evidence, scripts, and public release notes organized without depending on the
maintainer's private workstation.

## Top-Level Lanes

```text
.github/workflows/      public verifier-only GitHub Actions
anykernel3/             AnyKernel3 packaging lane and future checks
apks/                   APK packaging lane and future checks
container/              Droidspaces and Linux-container lane, paused for now
docs/                   public guides, notes, CI policy, and archives
evidence/               tracked evidence indexes, not raw private payload dumps
modules/                Magisk/KSU module lane and future checks
recovery/               OrangeFox/TWRP recovery source, manifests, patches, and archives
scripts/                local helpers, CI verifiers, and repo maintenance scripts
```

## Recovery Lane

```text
recovery/
  device/zte/sm88XX/        curated RM11 Pro OrangeFox device-tree snapshot
  manifests/                recovery hash manifests and baseline records
  patches/                  OrangeFox/TWRP source patch sets
  prebuilts/                public prebuilt policy and hash manifests
  archive-dead-ends/        preserved failed/probe recovery candidates
```

The active recovery baseline is D2N:

- Baseline note: `docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md`
- Local preflash verifier: `scripts/recovery/verify-d2n-preflash.sh`
- Image SHA-256: `a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0`
- Zip SHA-256: `5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab`

## CI Boundary

Public GitHub-hosted Actions are verifier-only. They may lint scripts, check
layout, check recorded hashes, and validate packaging metadata. They must not
run `repo sync`, full OrangeFox builds, flashing commands, private local paths,
secrets, or self-hosted runners.

Full recovery builds are local/fork-owner work. The documented lane is
`scripts/local-build/build-orangefox-nx809j-local.sh` with a user-owned
OrangeFox/AOSP workspace.
