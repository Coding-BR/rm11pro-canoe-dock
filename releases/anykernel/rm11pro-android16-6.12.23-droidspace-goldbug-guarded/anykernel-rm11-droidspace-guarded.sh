### AnyKernel3 Ramdisk Mod Script
## RM11 Pro / REDMAGIC 11 Pro guarded Droidspace kernel package.
## Kernel payload provenance: Goldzxcbug/sm8850_Droidspaces AnyKernel3 build.

properties() { '
kernel.string=RM11 Pro Android 16 6.12.23 Droidspace Goldbug guarded
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
do.check_boot_version=1
device.name1=NX809J
device.name2=NX809J-UN
device.name3=RM11Pro
device.name4=RedMagic 11 Pro
device.name5=REDMAGIC 11 Pro
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; }

BLOCK=boot
IS_SLOT_DEVICE=auto
RAMDISK_COMPRESSION=auto
PATCH_VBMETA_FLAG=0
NO_MAGISK_CHECK=1

. tools/ak3-core.sh

ui_print " "
ui_print "RM11 Pro Android 16 6.12.23 Droidspace Goldbug guarded"
ui_print "Target partition: boot only"
ui_print "Slot handling: auto"
ui_print "vbmeta patching: disabled"
ui_print " "

kernel_version=$(cat /proc/version 2>/dev/null | awk -F '-' '{print $1}' | awk '{print $3}')
case "$kernel_version" in
  6.12.23)
    ui_print "Kernel minor check passed: $kernel_version"
  ;;
  *)
    abort "Kernel minor mismatch. Expected 6.12.23, got: ${kernel_version:-unknown}"
  ;;
esac

product_device="$(getprop ro.product.device 2>/dev/null)"
product_model="$(getprop ro.product.model 2>/dev/null)"
product_name="$(getprop ro.product.name 2>/dev/null)"
case "$product_device:$product_model:$product_name" in
  *NX809J*|*RM11Pro*|*RedMagic*|*REDMAGIC*)
    ui_print "RM11 device identity check passed: $product_device / $product_model / $product_name"
  ;;
  *)
    abort "Device mismatch. Expected RM11 Pro / NX809J, got: $product_device / $product_model / $product_name"
  ;;
esac

split_boot

if [ -f "$SPLITIMG/ramdisk.cpio" ] || [ -f "split_img/ramdisk.cpio" ]; then
  unpack_ramdisk
  write_boot
else
  flash_boot
fi

ui_print " "
ui_print "Install complete."
ui_print "Use this Droidspace kernel only with a known-good stock boot rollback image."
ui_print " "
