# Required Files

Prepare tools before modifying the device:

- Current Android platform-tools.
- Google USB Driver on Windows.
- Qualcomm QDLoader driver for EDL visibility.
- ZTE/Nubia toolbox version that explicitly supports your model.
- Stock firmware matching your exact RM11 Pro firmware baseline.
- Engineering ABL only if confirmed for RM11 Pro / NX809J.
- Magisk if using the initial `init_boot` root path.
- KernelSU-Next Manager if validating the OP-WILD KSU/SUSFS package.
- Rollback copies of critical partitions.

Critical rollback set:

- `boot_a.img`
- `init_boot_a.img`
- `vendor_boot_a.img`
- `vbmeta_a.img`
- `vbmeta_system_a.img`
- Stock `recovery_a.img` before recovery tests.

Do not upload private partition dumps to this repo.
