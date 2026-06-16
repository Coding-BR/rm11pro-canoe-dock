# OrangeFox Build Result

D2N baseline:

- Build: PASS.
- Pre-flash verifier: PASS.
- Public prebuilt zip committed under `releases/recovery/orangefox/d2n-baseline`.
- Recovery image size: `104857600`.
- Recovery image SHA-256: `a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0`.
- OrangeFox zip SHA-256: `5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab`.
- Device result: booted to OrangeFox UI; touch, scrolling, and navigation worked.
- Classification: current NX809J/canoe recovery baseline, not a universal stable guarantee.

Original OrangeFox NX809J image:

- Build: PASS.
- `fastboot boot`: FAIL, `Bad Buffer Size`.
- `fastboot flash recovery_a`: PASS.
- Boot to recovery: FAIL, routed to fastboot.
- Stock `recovery_a` rollback: PASS.
- Android restored: PASS.

AVBTEST1 image:

- Build: PASS.
- Pre-flash image verification: PASS.
- Device-side flash/boot test: not performed in this repo state.
- Classification: avb-signed rebuild ready for cautious test.

AVBTEST1 hashes from build evidence:

```text
eb186188e7c18e7ef5ec8623ad4b1620b7dae3f9618075629008ff0ec2d6bd37  OrangeFox-R12.0-Unofficial-NX809J-avbtest1.img
d8301aa2cd42a8caf708ea6ddc26f574f797ec2da66a1fd971e9aa32816ed4e5  OrangeFox-R12.0-Unofficial-NX809J-avbtest1.zip
```

2026-06-09 stock-fstab/minimal-init candidate:

- Build: PASS.
- Pre-flash image verification: PASS.
- Device-side flash/boot test: not performed after this rebuild.
- Classification: one-slot cautious candidate only.

Hash:

```text
9a3d822bbe8201321934a3e746b6c2efc6ef4c037939a858e94487fd866e2d4d  OrangeFox-R12.0-Unofficial-NX809J.img
```

Local artifact:

```text
<orangefox-tree>/out/target/product/NX809J/OrangeFox-R12.0-Unofficial-NX809J.img
```
