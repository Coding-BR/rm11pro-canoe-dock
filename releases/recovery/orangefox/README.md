# OrangeFox WIP

Current classification:

```text
build-pass / recovery_a-dd-test-fail / rollback-pass / stockfstab-mininit-candidate-built
```

Artifacts are not committed here.

Current known images:

- Original failed image: `OrangeFox-R12.0-Unofficial-NX809J.img`.
- AVBTEST1 rebuilt image: `OrangeFox-R12.0-Unofficial-NX809J-avbtest1.img`.
- Current stock-fstab/minimal-init candidate: `OrangeFox-R12.0-Unofficial-NX809J.img`.

Do not retest the original failed image.

Do not treat AVBTEST1 as the next candidate unless intentionally comparing the
older AVB-only patch. The current candidate also reduces early recovery init and
fstab risk.

Current local candidate SHA-256:

```text
9a3d822bbe8201321934a3e746b6c2efc6ef4c037939a858e94487fd866e2d4d
```

Only test with one recovery slot and stock rollback ready.
