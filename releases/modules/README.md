# Modules

This folder tracks optional modules and RedMagic tooling.

Examples:

- RedMagic Control Center.
- Nubia Toolkit.
- Device-specific helper modules.

Current local module/tool references:

```text
<module-build-root>/gpp-enable-module
<module-build-root>/gpp-enable-module.zip
<module-build-root>/v34.3-Integrity-Box-04-04-2026
<toolbox-root>/NubiaToolkit
<toolbox-root>/Redmagic-Control-Center
<toolbox-root>/reversa
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
