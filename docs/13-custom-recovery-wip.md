# Custom Recovery WIP

Recovery work is WIP.

Current OrangeFox classification:

```text
build-pass / flash-pass / boot-fail / rollback-pass
```

Do not publish recovery as usable. Do not tell users to flash recovery yet.

Before recovery can be treated as usable, it needs:

- Boot to recovery UI.
- Touch.
- ADB.
- Basic mount behavior.
- Decryption/mount testing.
- Reboot to system.
- Stock recovery rollback verified.

Recovery work belongs in the OrangeFox/device-tree repo. Canoe Dock only publishes evidence, warnings, and release-ready references.
