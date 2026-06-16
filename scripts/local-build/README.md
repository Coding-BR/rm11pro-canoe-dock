# Local OrangeFox Build

This lane builds RM11 Pro / NX809J recovery in a local OrangeFox tree owned by
the person running the command. It does not use public GitHub Actions and does
not depend on the maintainer's WSL paths.

## Setup

1. Sync or otherwise prepare an OrangeFox/TWRP source tree locally.
2. Create an env file from `env-orangefox-nx809j.example`.
3. Set `ORANGEFOX_TREE` to that local source tree.
4. Adjust `LUNCH_TARGET` if you are building a specific candidate such as D2N.

## Build

```bash
scripts/local-build/build-orangefox-nx809j-local.sh --env scripts/local-build/env-orangefox-nx809j.local
```

The script injects or links `recovery/device/zte/sm88XX` into the OrangeFox tree,
runs the configured lunch target and build goals, then copies recovery images
and zips into `out/local-orangefox-nx809j` with `SHA256SUMS`.

## Safety Boundary

- No flashing.
- No `repo sync`.
- No self-hosted public runner.
- No secrets.
- No private maintainer paths.
- Existing unmanaged device trees are not overwritten unless the caller passes
  `--force-device-tree`.
