# Backups And Privacy

Back up before modifying anything.

Use EDL/toolbox backup flow only with tools known to support your exact model and firmware. Store backups off-device.

Minimum backup targets:

- `persist`
- `modemst1`
- `modemst2`
- `fsg`
- `init_boot`
- `boot`
- `vendor_boot`
- `vbmeta`
- `vbmeta_system`
- `recovery`

Privacy warning:

- Never flash another person's calibration partitions.
- Never publish your calibration partitions.
- Redact serials, IMEI, phone numbers, and account identifiers from public logs.

Treat your unlocked-state backup as the recovery anchor for later testing.
