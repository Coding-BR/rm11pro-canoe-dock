# Rollback

Keep a known-good stock recovery image before testing:

```powershell
fastboot flash recovery_a .\stock-recovery-a.img
fastboot reboot recovery
```

If you tested `recovery_b`, restore `recovery_b` instead.

Do not continue testing if:

- `fastboot getvar product` is not `canoe`.
- the target recovery partition size is not `0x6400000`.
- the OrangeFox `recovery.img` hash does not match the published hash.
- you do not have a stock rollback image for your slot.
