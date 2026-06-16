# Route 1 Safe Public CI

Date: 2026-06-15

Route 1 means public GitHub-hosted CI performs lightweight verification by
default. The only full-build exception is the experimental OrangeFox build and
release workflow, which runs on a public GitHub-hosted runner and is expected to
fail clearly if the runner does not have enough disk space.

## Allowed In Public Actions

- Check required docs, scripts, and lane directories exist.
- Verify recorded D2N baseline hashes.
- Run `bash -n` and ShellCheck on tracked shell scripts.
- Verify local verifier scripts are executable.
- Check packaging lanes have placeholder policy files.
- Run the experimental OrangeFox build/release workflow on manual dispatch.
  It updates the single fixed `orangefox-nx809j-latest` prerelease and replaces
  previous assets instead of accumulating automatic releases.

## Forbidden In Public Actions

- `runs-on: self-hosted`
- public PR jobs on a private workstation
- private local paths such as `<user-home>`
- secrets or tokens for build access
- full OrangeFox/AOSP builds outside the explicit build/release workflow,
  kernel builds, or flashing
- `adb`, `fastboot`, `dd`, or any device write action

## Full Builds

Full OrangeFox builds are attempted by
`.github/workflows/orangefox-build-release.yml` as an experimental public
runner path. GitHub-hosted standard runners may not have enough free disk for a
full OrangeFox/AOSP sync and build, so the workflow must print `df -h` before
and after large steps. If it fails for capacity, move the same workflow to a
larger runner or self-hosted runner. Successful runs publish to the single fixed
`orangefox-nx809j-latest` release.

## Current Recovery Gate

The public recovery workflow verifies repo evidence for D2N. The heavier
`scripts/recovery/verify-d2n-preflash.sh` remains a local preflash verifier
because it checks private lab artifacts and unpacked images.
