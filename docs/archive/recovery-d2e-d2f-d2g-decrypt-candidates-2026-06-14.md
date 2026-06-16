# D2E, D2F, D2G Decrypt Candidate State

Date: 2026-06-14

This note records the current RM11 Pro / NX809J OrangeFox decrypt-candidate lane.
Raw images and logs stay local under `<local-build-root>/recovery-forensics`.

## Summary

Current classification:

```text
d1t3-basic-ui-touch-navigation-pass / d2e-boot-adb-pass-crypto-disabled / d2f-crypto-enabled-animation-stall / d2g-preflash-marker-proof-pass-not-flashed
```

Do not publish recovery as usable yet.

## D2E

Result:

- Booted far enough to expose recovery ADB.
- `ro.orangefox.crypto_enabled=0`.
- Service-start probing did not solve decrypt.
- Classification: boot/ADB pass, crypto disabled, service-start fail.

## D2F

Result:

- Crypto lane enabled.
- Boot reached OrangeFox animation but did not reach the menu.
- Recovery ADB worked.
- Logs showed service restart loops around the decrypt/security runtime path.
- Classification: crypto enabled, animation stall, service restart loops.

## D2G

Intent:

- Keep the D2F crypto-enabled lane.
- Add explicit D2G manual-service triggers for `qseecomd`, keymint, gatekeeper, weaver, and secure element probing.

Frozen artifact:

```text
<local-build-root>/recovery-forensics/d2g-crypto-enabled-manual-service-overlay/OrangeFox-R12.0-Unofficial-NX809J-d2g-crypto-enabled-manual-service-overlay.img
size: 104857600
sha256: a806ffcc82eeec0ffd29d2c07f5f8e6c9a8669fce783ce3901e4f6711baa9664
```

Preflash status:

- AVB fingerprint contains `orangefox_NX809J_codingbr_d2g`.
- Built recovery root contains `ro.rm11.decrypt_candidate_d2g=d2g-crypto-enabled-manual-service-overlay` in `default.prop` and `prop.default`.
- Built recovery root contains all D2G manual triggers:
  - `sys.rm11.d2g.start_qseecomd`
  - `sys.rm11.d2g.start_keymint_qti`
  - `sys.rm11.d2g.start_gatekeeper`
  - `sys.rm11.d2g.start_weaver`
  - `sys.rm11.d2g.start_secure_element`
- D2G is not listed in `RM11_NO_DECRYPT_PRODUCTS`.
- D2G has a `TARGET_RECOVERY_DEVICE_DIRS` block that includes `$(DEVICE_PATH)/d2g`.
- `ro.orangefox.crypto_enabled` is a runtime property set from the `TW_INCLUDE_CRYPTO` compile lane in `bootable/recovery/twrp.cpp`; it is not expected as a static default property.

Local verification helper:

```bash
<repo-root>/scripts/recovery/verify-d2g-preflash.sh
```

Current decision:

- D2G marker/property inclusion is proven for the frozen artifact.
- D2G remains preflash-only until an intentional one-slot recovery test is chosen.
- Do not flash both recovery slots.
