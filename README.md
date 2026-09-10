# Galaxy Assistant

A small Windows/ADB utility for Samsung Galaxy devices. It can toggle the camera shutter-sound setting and display battery information exposed by the device.

[한국어 안내](docs/README.ko.md) · [English guide](docs/README.en.md)

## Features

- Enable or restore the Galaxy camera shutter-sound setting
- Read battery level, voltage, estimated health, and cycle data when the device exposes those fields
- Download, verify, and install the official Camsung 1.2.1 APK
- Korean and English interfaces

## Requirements

- Windows PC
- Samsung Galaxy device
- USB cable
- USB debugging enabled and authorized
- Android Debug Bridge (`adb`) available in `PATH`, or placed next to the batch file
- Windows PowerShell and internet access are required only for the Camsung installer

## Download

- [Korean script](galaxy-assistant-ko.bat)
- [English script](galaxy-assistant-en.bat)
- [ZIP bundle](https://github.com/Lumi-01/Galaxy-assistant/raw/refs/heads/main/Galaxy%20assistant.zip)

The ZIP contains the same current Korean and English batch scripts for convenient download.

## Compatibility notes

- Tested on Galaxy S25+ with One UI 8.1.
- A system update may reset the shutter-sound setting.
- The setting only takes effect where the device firmware and local regulations permit it; on supported devices, the phone may also need to be in Vibrate or Mute mode.
- Battery health and cycle fields are Samsung-specific and may be unavailable on some models or firmware versions.
- The Camsung installer downloads the pinned official 1.2.1 release and verifies its published SHA-256 before installation. Android 14 or later is handled with the required low-target-SDK bypass flag.
