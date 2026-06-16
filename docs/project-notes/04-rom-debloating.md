# ROM Debloating

## Status

Debloating is a separate ROM hygiene lane. It should not be mixed into kernel RAM-boot validation, recovery flashing, or root-provider migration.

The old notes had many keyword hits around `debloat`, package disable/uninstall, OTA disable, and ROM folders, but limited direct per-package proof.

## High-Confidence Debloat Item

OTA disable is the only debloat-like action that should be treated as project safety baseline.

Known package names from `rm11pro-canoe-dock`:

```powershell
adb shell pm disable-user --user 0 com.zte.zdm
adb shell pm disable-user --user 0 com.zte.zdmdaemon
adb shell pm disable-user --user 0 com.zte.zdmdaemon.install
```

Verification:

```powershell
adb shell pm list packages | findstr zte.zdm
adb shell pm list packages -d | findstr zte.zdm
```

Linux equivalent:

```bash
adb shell pm list packages | grep zte.zdm
adb shell pm list packages -d | grep zte.zdm
```

Package names may vary by firmware.

## Local ROM Folders

Potential debloat/deodex source folders:

- `/mnt/e/Android/RM-11-Pro/BOOT/04-ABL-Unlock-Debloat-16`
- `/mnt/e/Android/RM-11-Pro/BOOT/04-ABL-Unlock-Debloat-Deodex-16`

Treat these as asset folders only until inspected with hashes and manifests.

## Debloat Report Template

For every package removed/disabled:

- Package name.
- App label.
- Original partition/path if known.
- Disable vs uninstall vs delete.
- User/profile scope.
- Command used.
- Boot result.
- Broken features.
- Restore command or rollback image.

## What Helps Canoe Dock

Promote:

- OTA disable safety section.
- Debloat report template.
- confirmed package effects.

Do not promote:

- broad "safe to remove" lists without firmware match.
- deletion recipes without restore commands.
- package changes mixed into kernel/recovery validation logs.

## Source References

- `<repo-root>/docs/03-ota-disable.md`
- `<repo-root>/docs/xda-redmagic-11-pro-access-guide.md`
- `/mnt/e/Android/RM-11-Pro/BOOT/04-ABL-Unlock-Debloat-16`
- `/mnt/e/Android/RM-11-Pro/BOOT/04-ABL-Unlock-Debloat-Deodex-16`
