# GSI / ROM Flow

GSI and ROM notes in Canoe Dock are reports unless each build has its own validation page.

Current XDA source guide reports:

- Infinity X GSI.
- AOSP GSIs.
- Pixel-based GSIs.

Current limitations noted in source material:

- Gaming features may be partially broken.
- Kernel ecosystem is early.
- Recovery is not boot-proven.

Rule:

```powershell
fastboot reboot fastboot
```

Use fastbootd for GSI and dynamic partition flashing. Do not flash GSIs from normal bootloader fastboot.

Each GSI report should include:

- Device model.
- Firmware baseline.
- Slot.
- GSI name/build/date.
- Flash commands.
- Boot result.
- Hardware result.
- Broken features.
- Rollback result.
