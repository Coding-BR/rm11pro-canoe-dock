# Modules

This folder tracks optional modules and RedMagic tooling.

Examples:

- RedMagic Control Center.
- Nubia Toolkit.
- Device-specific helper modules.

Current local module/tool references:

```text
/mnt/e/Android/RM-11-Pro/MODULES/gpp-enable-module
/mnt/e/Android/RM-11-Pro/MODULES/gpp-enable-module.zip
/mnt/e/Android/RM-11-Pro/MODULES/v34.3-Integrity-Box-04-04-2026
/home/richtofen/android/toolbox/NubiaToolkit
/home/richtofen/android/toolbox/Redmagic-Control-Center
/home/richtofen/android/toolbox/reversa
```

The dock tracks only notes and manifests for these. Do not commit module zips,
DEX files, `.so` payloads, APKs, release keys, or build outputs here.

Each module note should include:

- Version.
- Root provider used for testing.
- Required Android baseline.
- Working features.
- Broken features.
- Uninstall/rollback path.

Do not include evasion guidance.
