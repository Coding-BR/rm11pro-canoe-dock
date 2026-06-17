# OrangeFox D2N Provenance

Published package:

```text
OrangeFox-RM11-D2N.zip
```

Baseline:

```text
D2N auto-decrypt UI gatekeeper polish
```

Associated baseline tag:

```text
recovery-route1-d2n-baseline-2026-06-15
```

Associated merge commit:

```text
83bdd11786e92c24a94eb2b7e696f80324c810d7
```

Hashes:

```text
5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab  OrangeFox zip
a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0  embedded recovery.img
```

Build lane summary:

- Device: RM11 Pro / REDMAGIC 11 Pro / NX809J / canoe.
- OrangeFox source lane: local/fork-owner controlled.
- Public CI lane: verifier-only.
- Recovery tree: `recovery/device/zte/sm88XX`.
- D2N preserved the D1T3 touch/UI baseline.

The raw D2N `recovery.img` is not committed separately because it is exactly
`104857600` bytes. The published zip contains that image as `recovery.img`.
