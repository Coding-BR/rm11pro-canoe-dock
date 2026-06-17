# Provenance

Artifact:

```text
OrangeFox-RM11.zip
```

Source lane:

```text
RM11 OrangeFox v4 selectable theme and splash cosmetic branch
```

Build target:

```text
lunch orangefox_NX809J_codingbr_d2n-ap2a-eng
mka recoveryimage
```

Built artifact hash:

```text
f2547c3ff9d43b060ba0ece1e9f497e2de0fbe0180a6eb8bdde3df01d80ce0d3  OrangeFox-RM11.zip
b3c0cdeb3efbedf0903eced3a840523fe735ec27082c9f1f2bd826884166187f  recovery.img
```

Device-side visual test:

```text
fastboot product: canoe
fastboot current-slot: a
target partition: recovery_a
recovery_a size: 0x6400000
result: rebooted into recovery; user reported success
```

Functional recovery baseline remains D2N. This package adds the RM11 cosmetic
theme/splash path on top of the working recovery lane.
