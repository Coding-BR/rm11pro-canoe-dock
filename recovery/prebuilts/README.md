# Recovery Prebuilts

This lane tracks policy and manifests for recovery prebuilts. It does not mirror
large proprietary binary trees by default.

Current public records:

- `android16-live-prebuilts.md`: what was captured from the live Android 16
  RM11 Pro baseline.
- `../manifests/android16-live-prebuilts.sha256`: SHA-256 manifest for that
  local capture.
- `recovery/device/zte/sm88XX/prebuilt/`: curated text/config subset imported with the
  public device-tree snapshot.

Full local builds still need a hydrated OrangeFox tree and the builder's own
legally available device prebuilts.
