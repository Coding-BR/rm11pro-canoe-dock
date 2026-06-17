# Rollback

Keep rollback files off-device before flashing:

- `boot_a.img`
- `init_boot_a.img`
- `vendor_boot_a.img`
- `vbmeta_a.img`
- `vbmeta_system_a.img`

If the AnyKernel package causes boot failure or root failure, restore the known-good `boot_a.img` first.

Example commands, adjust slot only if your tested slot is different:

```powershell
fastboot flash boot_a boot_a.img
fastboot reboot
```

If boot-chain consistency is still broken, restore the broader rollback set:

```powershell
fastboot flash init_boot_a init_boot_a.img
fastboot flash vendor_boot_a vendor_boot_a.img
fastboot flash vbmeta_a vbmeta_a.img
fastboot flash vbmeta_system_a vbmeta_system_a.img
fastboot reboot
```

Do not use rollback images from another device.
