# Route 1 PR Review

Date: 2026-06-15

Last updated: 2026-06-16

Branch: `repo-ci-route1-safe-public`

## Reviewed Commits

- `e42d09a` Start Route 1 safe public CI lane
- `d33109c` Organize RM11 Pro recovery build tree
- `b84297f` Add local OrangeFox build scripts
- `bf44115` Add safe recovery verifier workflow
- `2c0e6e8` Archive recovery dead-end candidates
- `8e7b129` Add Route 1 PR review note
- final hygiene pass: scrub public-facing private maintainer paths

## Workflows Added

- `.github/workflows/recovery-verify.yml`
- `.github/workflows/anykernel3-verify.yml`
- `.github/workflows/apk-verify.yml`
- `.github/workflows/module-verify.yml`

All root workflows use `ubuntu-latest` and `permissions: contents: read`.

## Safety Checks Performed

- Checked root workflows for `self-hosted`: none found.
- Checked root workflows for `secrets.`: none found.
- Checked root workflows for `adb`, `fastboot`, `dd if=`, and flashing-style commands: none found.
- Checked root workflows for `repo sync`: none found.
- Checked root workflows for private Linux home paths: none found.
- Checked Route 1 verifier policy rejects self-hosted runners, private maintainer paths, repo sync, adb, fastboot, dd partition access, and GitHub secrets in root workflows.
- Checked local OrangeFox build lane remains local-only and user-editable through `scripts/local-build/env-orangefox-nx809j.example`.
- Checked local build script does not run `repo sync`, does not flash, does not use Actions, and refuses to overwrite unmanaged device trees unless explicitly forced.
- Replaced public-facing private maintainer paths with placeholders such as `<repo-root>`, `<orangefox-tree>`, `<local-build-root>`, and `<user-home>`.
- Replaced active script defaults with `$HOME`, repo-relative paths, env vars, or placeholders instead of maintainer-specific paths.

Tracked PR content no longer contains the literal maintainer home path. The
literal path remains only in intentionally untouched local worktree material:
the paused Droidspaces note and ignored setup-copy files. Those are not part of
the Route 1 PR content.

## D2N Baseline Hashes

Image:

```text
a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0  OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.img
```

Zip:

```text
5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab  OrangeFox-R12.0-Unofficial-NX809J-d2n-auto-decrypt-ui-gatekeeper-polish.zip
```

Recorded in:

- `docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md`
- `recovery/manifests/d2n-baseline.sha256`
- `scripts/recovery/verify-d2n-preflash.sh` for the image hash

## Verification

Local command:

```bash
scripts/ci/verify-recovery-route1.sh
```

Result: PASS.

GitHub Actions on the pushed branch passed for:

- Recovery Verify
- AnyKernel3 Verify
- APK Verify
- Module Verify

Final hygiene checks:

- `git grep` found no literal maintainer home path in tracked PR content after excluding the intentionally untouched Droidspaces note and unrelated release deletion state.
- `.github/workflows/` contains no private maintainer home path.
- `scripts/ci/` contains no private maintainer home path.
- D2N image and zip hashes are unchanged.

## Untouched Local Files

These local worktree changes were intentionally not included in the Route 1 PR:

- `docs/project-notes/15-droidspace-container-lane.md`
- `releases/anykernel/README.md`
- `releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/PROVENANCE.md`
- `releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/README.md`
- `releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/ROLLBACK.md`
- `releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/VERIFY.md`
- `releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/anykernel-rm11-guardrails.patch`
- `releases/anykernel/rm11pro-android16-6.12.23-opwild-ksun-susfs/hashes.sha256`
- `releases/gsi-roms/README.md`
- `releases/modules/README.md`
- `releases/recovery/README.md`
- `releases/recovery/orangefox/BUILD-RESULT.md`
- `releases/recovery/orangefox/FORENSICS.md`
- `releases/recovery/orangefox/README.md`
- `releases/recovery/orangefox/ROLLBACK.md`

## Merge Recommendation

Safe to open and merge after review.

Recommended merge method: create a merge commit. This preserves the five
logical commits as reviewed. Avoid squash merge for this PR because it hides the
requested commit boundaries.

Do not merge automatically from tooling; wait for explicit maintainer approval.

## Suggested PR

Title:

```text
Prepare Route 1 safe public CI lane
```

Body:

```text
## Summary
- add verifier-only public GitHub Actions for recovery, AnyKernel3, APK, and module lanes
- move the curated RM11 Pro OrangeFox recovery tree under recovery/device/zte/sm88XX
- add local-only OrangeFox build scripts and D2N baseline hash records
- archive superseded recovery candidate diffs and verifier drafts

## Safety
- no self-hosted runners
- no secrets
- no adb, fastboot, dd, flashing, or repo sync in public workflows
- full OrangeFox builds remain local/fork-owner work
- D2N hashes remain recorded in docs and recovery manifests

## Verification
- scripts/ci/verify-recovery-route1.sh
- GitHub Actions: Recovery Verify, AnyKernel3 Verify, APK Verify, Module Verify
```
