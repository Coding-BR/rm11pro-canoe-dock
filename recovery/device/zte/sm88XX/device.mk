#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/nubia/NX809J

# Configure base.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Configure core_64_bit_only.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Configure virtual_ab_ota launch_with_vendor_ramdisk.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Configure emulated_storage.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Configure twrp config common.mk
$(call inherit-product, vendor/twrp/config/common.mk)

# API
# The live RM11 Android baseline is API 36, recorded in system.prop and docs.
# Do not force BOARD/PRODUCT_SHIPPING_API_LEVEL=36 here: the current
# OrangeFox 14.1/minimal AP2A build base only supports SystemSDK through 34.

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# Required for Android 16 CrashRecovery APEX

# Enable Fuse Passthrough
PRODUCT_PROPERTY_OVERRIDES += persist.sys.fuse.passthrough.enable=true

# Otacert
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(DEVICE_PATH)/security/releasekey

# Required modules
TWRP_REQUIRED_MODULES += \
    prebuilt

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# fstab - copied to both recovery root and vendor ramdisk for first-stage init
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/recovery.fstab \
    $(DEVICE_PATH)/recovery.fstab:$(TARGET_VENDOR_RAMDISK_OUT)/first_stage_ramdisk/fstab.qcom \
    $(DEVICE_PATH)/recovery/root/vendor/etc/vintf/manifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest.xml \
    $(DEVICE_PATH)/recovery/root/lib/modules/modules.blocklist:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.blocklist \
    $(DEVICE_PATH)/prebuilt/android16/system/bin/keystore2:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/keystore2 \
    $(DEVICE_PATH)/prebuilt/android16/system/lib64/libkeystore2_aaid.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libkeystore2_aaid.so \
    $(DEVICE_PATH)/prebuilt/android16/system/lib64/libkeystore2_apc_compat.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libkeystore2_apc_compat.so \
    $(DEVICE_PATH)/prebuilt/android16/system/lib64/libkeystore2_crypto.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libkeystore2_crypto.so \
    $(DEVICE_PATH)/prebuilt/android16/system/lib64/libkm_compat_service.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libkm_compat_service.so \
    $(DEVICE_PATH)/prebuilt/android16/system/lib64/libbinder_ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libbinder_ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/system/etc/vintf/manifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/vintf/manifest.xml

# Android 16 live crypto and qsee service prebuilts
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/android16/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/android.hardware.security.onekeymint-service-qti.rc \
    $(DEVICE_PATH)/prebuilt/android16/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/android.hardware.gatekeeper-service-qti.rc \
    $(DEVICE_PATH)/prebuilt/android16/vendor/etc/init/qseecomd.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/qseecomd.rc \
    $(DEVICE_PATH)/prebuilt/android16/vendor/etc/vintf/manifest/android.hardware.security.onekeymint-service-qti.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/android.hardware.security.onekeymint-service-qti.xml \
    $(DEVICE_PATH)/prebuilt/android16/vendor/etc/vintf/manifest/android.hardware.gatekeeper-service-qti.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/android.hardware.gatekeeper-service-qti.xml \
    $(DEVICE_PATH)/prebuilt/android16/vendor/bin/hw/android.hardware.security.onekeymint-service-qti:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/android.hardware.security.onekeymint-service-qti \
    $(DEVICE_PATH)/prebuilt/android16/vendor/bin/hw/android.hardware.gatekeeper-rust-service-qti:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/android.hardware.gatekeeper-rust-service-qti \
    $(DEVICE_PATH)/prebuilt/android16/vendor/bin/qseecomd:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/qseecomd \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.gatekeeper-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.gatekeeper-V1-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.gatekeeper@1.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.gatekeeper@1.0.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.keymaster-V3-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.keymaster-V3-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.keymaster-V4-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.keymaster-V4-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.keymaster@3.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.keymaster@3.0.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.keymaster@4.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.keymaster@4.0.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.keymaster@4.1.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.keymaster@4.1.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.security.keymint-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.security.keymint-V1-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.security.keymint-V2-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.security.keymint-V2-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.hardware.security.keymint-V4-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.security.keymint-V4-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/android.system.keystore2-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.system.keystore2-V1-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/com.qti.qseeaon.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/com.qti.qseeaon.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/com.qti.qseeutils.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/com.qti.qseeutils.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libQSEEComAPI.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libQSEEComAPI.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libgatekeeper.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libgatekeeper.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libkeymaster_messages.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libkeymaster_messages.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libkeymasterdeviceutils.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libkeymasterdeviceutils.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libkeymasterprovision.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libkeymasterprovision.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libkeymasterutils.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libkeymasterutils.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libqseed3.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libqseed3.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libqtikeymaster4.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libqtikeymaster4.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libspukeymint.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libspukeymint.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libspukeymintdeviceutils.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libspukeymintdeviceutils.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libspukeymintprovision.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libspukeymintprovision.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/libspukeymintutils.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libspukeymintutils.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/vendor.qti.hardware.qseecom-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/vendor.qti.hardware.qseecom-V1-ndk.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/vendor.qti.hardware.qseecom@1.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/vendor.qti.hardware.qseecom@1.0.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/hw/libqtigatekeeper.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/libqtigatekeeper.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/hw/libspuqtigatekeeper.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/libspuqtigatekeeper.so \
    $(DEVICE_PATH)/prebuilt/android16/vendor/lib64/hw/vendor.qti.hardware.qseecom@1.0-impl.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/vendor.qti.hardware.qseecom@1.0-impl.so

# Init scripts
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/init.recovery.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.wifi.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.wifi.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.haptics.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.haptics.rc
