# Recovery Forensics Manifest

The local raw forensics folder is:

```text
/home/richtofen/android/repositories/MainAssets/recovery-forensics
```

It contains raw recovery images, unpacked ramdisks, AVB output, headers, and file lists.

Raw evidence is intentionally not tracked in git:

- Recovery images are 100 MB each.
- Unpacked ramdisk workspaces used to include thousands of extracted files and were deleted as reproducible junk.
- Git saw 4179 unignored files before the folder-level ignore rule.
- Several files are generated binaries or device payloads that should stay local.

Tracked summaries instead:

- `rm11-orangefox-image-format-forensics-2026-06-07.md`
- `rm11-orangefox-avbtest1-image-format-comparison-2026-06-07.md`
- `rm11-orangefox-flash-pass-boot-fail-rollback-pass-2026-06-07.md`
- `rm11-orangefox-build-pass-2026-06-07.md`

Local raw evidence folders:

- `/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-2026-06-07`
- `/home/richtofen/android/repositories/MainAssets/recovery-forensics/rm11-orangefox-avbtest1-2026-06-07`

Important raw evidence classes:

- `logs/*avbtool-info.txt`: AVB footer and descriptor details.
- `logs/*unpack_bootimg*`: boot image header parsing details.
- `logs/*magiskboot*`: magiskboot unpack component summaries.
- `logs/*comparison.txt`: stock, failed OrangeFox, and AVBTEST1 comparisons.
- `headers/*.xxd`: first and last 4096 bytes of the compared images.
- extracted ramdisk trees and unpack workspaces were deleted; they are reproducible from the kept images.

Image lineage captured by the summaries:

- Stock `recovery_a`: header v4, ramdisk-only, `SHA256_RSA4096`, rollback index `1`.
- Failed OrangeFox: header v4, ramdisk-only, algorithm `NONE`, rollback index `0`.
- AVBTEST1 OrangeFox: header v4, ramdisk-only, `SHA256_RSA4096`, rollback index `1`, generated validation key.

Policy:

- Keep raw forensic payloads local.
- Commit summaries, manifests, scripts, and reproducible commands.
- If a raw binary must be shared, publish it as a release artifact with explicit warning labels, not as a normal git blob.
