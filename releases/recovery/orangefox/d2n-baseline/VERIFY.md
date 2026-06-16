# Verify OrangeFox D2N Baseline

Local hash check:

```bash
sha256sum OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.zip
```

Expected:

```text
5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab
```

Confirm the zip contains the D2N image:

```bash
unzip -l OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.zip
```

Expected embedded image:

```text
recovery.img
size: 104857600
sha256: a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0
```

The repo-level verifier is:

```bash
scripts/ci/verify-recovery-route1.sh
```

That verifier performs public CI-safe checks only. It does not flash, push,
pull, or write to a device.
