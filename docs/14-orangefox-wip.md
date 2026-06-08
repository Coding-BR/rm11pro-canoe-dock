# OrangeFox WIP

Current OrangeFox result:

```text
build-pass / flash-pass / boot-fail / rollback-pass
```

Known facts:

- `fastboot boot OrangeFox-R12.0-Unofficial-NX809J.img` failed with `Bad Buffer Size`.
- `fastboot flash recovery_a OrangeFox-R12.0-Unofficial-NX809J.img` passed.
- Device routed to fastboot instead of recovery.
- Stock `recovery_a` rollback passed.
- Android boot was restored.

Forensic finding:

- Stock and OrangeFox are both Android boot image header v4 ramdisk-only recovery images.
- Hard mismatch is AVB metadata.
- Stock recovery has signed `SHA256_RSA4096` recovery footer with rollback index `1`.
- Failed OrangeFox had `Algorithm: NONE`, rollback index `0`, and no auth block.
- AVBTEST1 uses a generated validation key, not the OEM key.
- If RM11 accepts non-stock recovery AVB keys when unlocked, AVBTEST1 is the next cautious test.
- If RM11 requires the OEM recovery key, it may still route to fastboot.

Current warning:

- Do not publish OrangeFox as usable.
- Do not flash the original failed image again.
- Keep stock `recovery_a` rollback available before any recovery test.
- Keep recovery WIP until UI, touch, ADB, mount/decryption behavior, and reboot-to-system pass.
