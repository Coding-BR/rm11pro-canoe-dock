# OrangeFox Forensics

Forensic summary:

- Stock recovery and failed OrangeFox are both Android boot image header v4 ramdisk-only recovery images.
- Both are exactly recovery partition sized.
- Both have no embedded kernel component.
- The boot kernel and DTB are expected to come from the normal boot/vendor_boot boot chain.

Hard mismatch:

- Stock recovery AVB footer:
  - Algorithm: `SHA256_RSA4096`.
  - Rollback index: `1`.
  - Rollback index location: `0`.
  - Authentication block present.
- Failed OrangeFox AVB footer:
  - Algorithm: `NONE`.
  - Rollback index: `0`.
  - Rollback index location: `0`.
  - Authentication block absent.

AVBTEST1:

- Uses `SHA256_RSA4096`.
- Uses rollback index `1`.
- Uses rollback location `0`.
- Uses a generated validation key, not the stock/OEM recovery key.

2026-06-09 stock-fstab/minimal-init candidate:

- Keeps the AVBTEST-style `SHA256_RSA4096` / rollback index `1` recovery footer.
- Replaces the vendor_boot-derived recovery fstab with the stock recovery_a fstab shape.
- Replaces the aggressive recovery qcom init hook with the stock-minimal qcom hook.
- Does not prove UI, touch, ADB, MTP, decryption, or reboot behavior.

Risk:

- If unlocked RM11 accepts non-stock recovery AVB keys, AVBTEST1 may be the next useful controlled test.
- If RM11 requires the OEM recovery key for recovery, AVBTEST1 may still route to fastboot.
- If the RedMagic logo hang was caused by fstab/init mismatch, the stock-fstab/minimal-init candidate is the more useful next test.
