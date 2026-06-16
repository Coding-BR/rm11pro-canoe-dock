# Modules And Tools

Optional tools are device-specific and should be treated as independent risk surfaces.

Known references from source material:

- Magisk.
- KernelSU-Next.
- RedMagic Control Center.
- Nubia Toolkit.
- MIO Kitchen.
- OrangeFox.
- Droidspaces reference artifact path.
- Fractal-Echo RM11 lab work.

Current local paths:

```text
/mnt/e/Android/RM-11-Pro/MODULES
<local-build-root>/toolbox/NubiaToolkit
<local-build-root>/toolbox/Redmagic-Control-Center
<local-build-root>/toolbox/reversa
```

Observed local module payloads:

- `gpp-enable-module`: tiny module tree plus ZIP, local-only until tested.
- `v34.3-Integrity-Box-04-04-2026`: contains scripts, DEX, keybox material, web UI, and native `.so` payloads; keep out of the public repo.
- `attestation`: local-only binary/text artifact, not classified for release.

Observed toolbox repos:

- `NubiaToolkit`: LSPosed/root RedMagic customization app; local checkout contains a release key and build files, so only notes belong here.
- `Redmagic-Control-Center`: root-level RedMagic hardware control app; use as APK customization/hardware-control research, not as a recovery prerequisite.
- `reversa`: reverse-documentation framework; useful for APK/tooling analysis workflow notes.

Module/testing notes should include:

- Exact app/module version.
- Required root provider.
- Whether Magisk or KernelSU was active.
- Android build.
- Broken RedMagic features, if any.
- Rollback or uninstall path.

Do not include guidance for evading app checks.
