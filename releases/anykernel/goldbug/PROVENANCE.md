# Provenance

Published package:

```text
AK3-RM11-Goldbug.zip
```

Source package:

```text
AnyKernel3_gki_6.12.23_Gold_bug.zip
```

Observed source metadata:

```text
Author: Goldzxcbug
Repo: Goldzxcbug/sm8850_Droidspaces
Branch: main
Run ID: 24273037293
Commit: 77c40756e83f55709974a77ae6411b44f9b0cf02
Kernel Ver: 6.12.23_gki-Gold_bug
```

Source package SHA-256:

```text
faf6dae488ab127e7d7ead183d68cb28592b537f8664b21f7017f825097aefb0
```

Payload Image SHA-256:

```text
286c57152a5e1169b947d80850aea1eee8cc602f61c769b2059304783c8acd39
```

Why this package exists:

- The raw Gold_bug package had `do.devicecheck=0`.
- The raw Gold_bug package had empty `device.name*` fields.
- The raw Gold_bug package used automatic vbmeta behavior.
- This package keeps the Gold_bug kernel payload but replaces the installer
  script with RM11/NX809J guardrails.

Guarded installer script:

```text
anykernel-rm11-goldbug-guarded.sh
sha256: f6d1c106b02eaeb22a365a06e79457bea345858547baf53bab104e0858396e15
```
