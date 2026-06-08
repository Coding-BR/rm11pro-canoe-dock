# OrangeFox Build Result

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
