#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/nubia/NX809J

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

# Device identifier
PRODUCT_DEVICE := NX809J
PRODUCT_NAME := orangefox_NX809J
PRODUCT_BRAND := REDMAGIC
PRODUCT_MANUFACTURER := nubia
PRODUCT_MODEL := REDMAGIC 11 Pro

# Assert
TARGET_OTA_ASSERT_DEVICE := NX809J

# Fingerprint
BUILD_FINGERPRINT := REDMAGIC/NX809J-UN/NX809J:16/BQ2A.250705.001-BP2A.250605.031.A3/20260320.095121:user/release-keys

# Theme
TW_STATUS_ICONS_ALIGN := center
