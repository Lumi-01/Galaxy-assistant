# Galaxy Assistant

A small Windows/ADB utility for Samsung Galaxy devices. It can toggle the camera shutter-sound setting and display battery information exposed by the device.

[한국어 안내](docs/README.ko.md) · [English guide](docs/README.en.md)

## Features

- Enable or restore the Galaxy camera shutter-sound setting
- Read battery level, voltage, estimated health, and cycle data when the device exposes those fields
- Retain every raw `dumpsys battery` result as a timestamped file in the `logs` folder
- Check, download, verify, and install the latest official Camsung release
- Korean and English interfaces

## Requirements

- Windows PC
- Samsung Galaxy device
- USB cable
- USB debugging enabled and authorized
- No separate ADB installation is needed when using the ZIP bundle; it includes the official Google ADB runtime for Windows
- Windows PowerShell and internet access are required only for the Camsung installer

## Download

- [Korean script](galaxy-assistant-ko.bat)
- [English script](galaxy-assistant-en.bat)
- [ZIP bundle](https://github.com/Lumi-01/Galaxy-assistant/raw/refs/heads/main/Galaxy%20assistant.zip)

The ZIP contains the Korean and English batch scripts plus the files required to run ADB on Windows. Extract the complete ZIP before running a script; do not move only the batch file out of the extracted folder.

The scripts prefer the bundled `platform-tools\adb.exe`, then an `adb.exe` beside the script, and finally an `adb` available in `PATH`.

The bundled `adb.exe`, `AdbWinApi.dll`, and `AdbWinUsbApi.dll` are included unchanged from Google's Windows Platform Tools 37.0.1 package. Google's `NOTICE.txt` and `source.properties` are included alongside them. Unrelated tools such as `fastboot` are intentionally not bundled.

## Automated tests

GitHub Actions runs the scripts on Windows with mocked ADB and PowerShell commands. It checks menu exit, bracketed Samsung battery metrics, Android 13 and Android 14 installation branches, missing-device handling, and APK hash rejection. The non-interactive `--battery` and `--install-camsung` arguments exist for these test paths; normal users can continue to use menus `4` and `5`.

## Compatibility notes

- Tested on Galaxy S25+ with One UI 8.1 and with Android 17 / One UI 9.0 Beta.
- A system update may reset the shutter-sound setting.
- The setting only takes effect where the device firmware and local regulations permit it; on supported devices, the phone may also need to be in Vibrate or Mute mode.
- Battery health and cycle fields are Samsung-specific and may be unavailable on some models or firmware versions.
- Battery checks keep their complete raw logs in the `logs` folder beside the scripts for later inspection.
- The Camsung installer queries the official GitHub latest-release API, requires the release asset's SHA-256 digest, and installs the APK only after verifying it. Android 14 or later is handled with the required low-target-SDK bypass flag.
- Bundled ADB version: 37.0.1. Its license notices are included in `platform-tools/NOTICE.txt`.
