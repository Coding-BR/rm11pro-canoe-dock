# Verify OrangeFox RM11 Current Test

Local hash check:

```bash
sha256sum OrangeFox-RM11.zip
```

Expected:

```text
f2547c3ff9d43b060ba0ece1e9f497e2de0fbe0180a6eb8bdde3df01d80ce0d3
```

Confirm the zip contains the recovery image:

```bash
unzip -l OrangeFox-RM11.zip
```

Expected embedded image:

```text
recovery.img
size: 104857600
sha256: b3c0cdeb3efbedf0903eced3a840523fe735ec27082c9f1f2bd826884166187f
```

Public CI checks repo safety only. It does not flash, push, pull, or write to a
device.
