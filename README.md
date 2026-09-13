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
- No separate ADB installation is needed when using the ZIP bundle; it includes the official Google Android SDK Platform Tools for Windows
- Windows PowerShell and internet access are required only for the Camsung installer

## Download

- [Korean script](galaxy-assistant-ko.bat)
- [English script](galaxy-assistant-en.bat)
- [ZIP bundle](https://github.com/Lumi-01/Galaxy-assistant/raw/refs/heads/main/Galaxy%20assistant.zip)

The ZIP contains the Korean and English batch scripts plus Google Android SDK Platform Tools for Windows. Extract the complete ZIP before running a script; do not move only the batch file out of the extracted folder.

The scripts prefer the bundled `platform-tools\adb.exe`, then an `adb.exe` beside the script, and finally an `adb` available in `PATH`.

## Automated tests

GitHub Actions runs the scripts on Windows with mocked ADB and PowerShell commands. It checks menu exit, Android 13 and Android 14 installation branches, missing-device handling, and APK hash rejection. The non-interactive `--install-camsung` argument exists for this test path; normal users can continue to use menu `5`.

## Compatibility notes

- Tested on Galaxy S25+ with One UI 8.1.
- A system update may reset the shutter-sound setting.
- The setting only takes effect where the device firmware and local regulations permit it; on supported devices, the phone may also need to be in Vibrate or Mute mode.
- Battery health and cycle fields are Samsung-specific and may be unavailable on some models or firmware versions.
- The Camsung installer downloads the pinned official 1.2.1 release and verifies its published SHA-256 before installation. Android 14 or later is handled with the required low-target-SDK bypass flag.
- Bundled Platform Tools version: 37.0.1. Its license notices are included in `platform-tools/NOTICE.txt`.
