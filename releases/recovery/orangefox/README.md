# OrangeFox Recovery Releases

Current public prebuilt:

- [OrangeFox RM11 current test](current/README.md)

The generated GitHub Actions prerelease `orangefox-nx809j-latest` is currently
build-only evidence. Its 2026-06-17 device-side test stalled on the REDMAGIC
logo after flashing `recovery_b`; it needs correction before it is treated as a
usable recovery artifact.

D2N is the current RM11 Pro / REDMAGIC 11 Pro / NX809J recovery baseline. It
booted to OrangeFox UI in the recovery lane and preserved the D1T3 touch/UI
baseline. Treat it as the current baseline/release candidate, not a universal
stable guarantee.

Committed prebuilt:

```text
current/OrangeFox-RM11.zip
d2n/OrangeFox-RM11-D2N.zip
```

Hashes:

```text
f2547c3ff9d43b060ba0ece1e9f497e2de0fbe0180a6eb8bdde3df01d80ce0d3  OrangeFox-RM11.zip
b3c0cdeb3efbedf0903eced3a840523fe735ec27082c9f1f2bd826884166187f  embedded current recovery.img
5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab  OrangeFox-RM11-D2N.zip
a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0  embedded D2N recovery.img
```

The raw `recovery.img` is not committed separately because it is exactly
`104857600` bytes. The committed OrangeFox zips contain that image as
`recovery.img`.

Historical failed/probe candidates remain documented in:

- [Build Result](BUILD-RESULT.md)
- [Forensics](FORENSICS.md)
- [Rollback](ROLLBACK.md)

Only test recovery with one recovery slot and stock rollback ready.
