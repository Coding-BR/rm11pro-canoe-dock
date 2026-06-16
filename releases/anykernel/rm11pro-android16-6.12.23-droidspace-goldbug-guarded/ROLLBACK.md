# Droidspace Goldbug Guarded AnyKernel3 Rollback

Before testing this kernel, keep a known-good stock `boot_a` and `boot_b` image
off-device.

This package targets `boot` only and does not intentionally patch vbmeta.

If the kernel fails to boot or Droidspace testing regresses critical behavior,
restore the tested boot slot from your known-good stock boot backup through your
local rollback path.

Do not continue kernel testing until Android boot, root state, and the stock
boot rollback path are confirmed.
