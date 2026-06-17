# OrangeFox D2N Baseline

Prebuilt:

```text
OrangeFox-RM11-D2N.zip
```

Classification:

```text
current RM11 Pro NX809J/canoe recovery baseline
```

This is the public D2N OrangeFox baseline for RM11 Pro / REDMAGIC 11 Pro /
NX809J. It is provided for users who want the current recovery artifact without
building OrangeFox locally.

Do not treat this as a universal stable guarantee. It is tied to the tested
NX809J/canoe recovery lane and should be used only with a known-good stock
recovery rollback path.

Hashes:

```text
5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab  OrangeFox-RM11-D2N.zip
a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0  embedded recovery.img
```

Known status:

- Image size verified: `104857600`.
- Zip contains `recovery.img`.
- Booted to OrangeFox UI in recovery testing.
- Touch, scroll, and navigation worked in OrangeFox UI.
- Public GitHub Actions remain verifier-only.
- Full OrangeFox builds remain local/fork-owner controlled.

Related docs:

- `docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md`
- `recovery/manifests/d2n-baseline.sha256`
- `scripts/recovery/verify-d2n-preflash.sh`
