# OrangeFox D2N Rollback

Before any recovery test, keep known-good stock `recovery_a` and `recovery_b`
images off-device.

Use one recovery slot for first tests. Do not write both slots until UI, touch,
MTP/ADB expectations, decryption expectations, and reboot-to-system behavior are
confirmed for your firmware state.

If a recovery test fails, restore only the tested recovery slot from your stock
backup through your known local rollback path.

Do not continue recovery testing until Android boot and stock recovery rollback
are both confirmed.
