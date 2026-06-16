# Route 1 Safe Public CI

Date: 2026-06-15

Route 1 means public GitHub-hosted CI performs only lightweight verification.
It does not build full Android trees and does not run on the maintainer's
machine.

## Allowed In Public Actions

- Check required docs, scripts, and lane directories exist.
- Verify recorded D2N baseline hashes.
- Run `bash -n` and ShellCheck on tracked shell scripts.
- Verify local verifier scripts are executable.
- Check packaging lanes have placeholder policy files.

## Forbidden In Public Actions

- `runs-on: self-hosted`
- public PR jobs on a private workstation
- private local paths such as `<user-home>`
- secrets or tokens for build access
- `repo sync`, full OrangeFox/AOSP builds, kernel builds, or flashing
- `adb`, `fastboot`, `dd`, or any device write action

## Full Builds

Full OrangeFox builds stay local to the person doing the build, or move to an
explicitly owned runner later. A fork owner may run the local build scripts in
their own hydrated source tree. This repository does not grant anyone access to
the maintainer's WSL install, device, keys, or private artifact folders.

## Current Recovery Gate

The public recovery workflow verifies repo evidence for D2N. The heavier
`scripts/recovery/verify-d2n-preflash.sh` remains a local preflash verifier
because it checks private lab artifacts and unpacked images.
