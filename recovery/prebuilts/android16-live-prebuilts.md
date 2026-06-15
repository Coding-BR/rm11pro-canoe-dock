# Android 16 Live Prebuilts

Source: live REDMAGIC 11 Pro / NX809J running Android 16, captured with Magisk root on 2026-06-07.

These files are staged separately from the inherited `prebuilt/system` and `prebuilt/dtbo.img` files so the old inputs remain available for comparison.

Included:

- `dtbo.img` from `/dev/block/by-name/dtbo_a`
- system keystore userspace files from `/system`
- vendor onekeymint, gatekeeper, and qsee init files and manifests
- vendor onekeymint, gatekeeper, and qsee service binaries
- vendor keymint, gatekeeper, and qsee support libraries

Use `manifest.sha256` to verify local file integrity.

This does not prove recovery decryption. It only removes a known mismatch between inherited prebuilts and the live Android 16 device.
