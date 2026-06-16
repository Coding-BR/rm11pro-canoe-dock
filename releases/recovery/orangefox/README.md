# OrangeFox Recovery Releases

Current public prebuilt:

- [D2N baseline](d2n-baseline/README.md)

D2N is the current RM11 Pro / REDMAGIC 11 Pro / NX809J recovery baseline. It
booted to OrangeFox UI in the recovery lane and preserved the D1T3 touch/UI
baseline. Treat it as the current baseline/release candidate, not a universal
stable guarantee.

Committed prebuilt:

```text
d2n-baseline/OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.zip
```

Hashes:

```text
5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab  OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.zip
a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0  embedded recovery.img
```

The raw `recovery.img` is not committed separately because it is exactly
`104857600` bytes. The committed OrangeFox zip contains that image as
`recovery.img`.

Historical failed/probe candidates remain documented in:

- [Build Result](BUILD-RESULT.md)
- [Forensics](FORENSICS.md)
- [Rollback](ROLLBACK.md)

Only test recovery with one recovery slot and stock rollback ready.
