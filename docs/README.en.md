# Galaxy Assistant guide

## Preparation

1. Extract the complete ZIP into one folder. It includes ADB and its required DLLs from the official Google Platform Tools package, so no separate `adb` installation is required.
2. On the phone, open **Settings → About phone → Software information**.
3. Tap **Build number** seven times to enable Developer options.
4. Open **Settings → Developer options** and enable **USB debugging**.
5. Connect the phone by USB and approve the debugging prompt on the phone.

## Run

Run `galaxy-assistant-en.bat`, then enter a menu number.

Keep the `platform-tools` folder beside the batch files. Moving only a batch file elsewhere prevents it from finding the bundled ADB.

- `1`: USB debugging instructions
- `2`: Disable the forced shutter-sound setting
- `3`: Restore the shutter-sound setting
- `4`: Display available battery information
- `5`: Download, verify, and install the official Camsung 1.2.1 APK
- `6`: Exit

## Installing Camsung

Menu `5` downloads the 1.2.1 APK from the [official Camsung GitHub repository](https://github.com/ericswpark/camsung). It installs the APK only after matching the SHA-256 published with the release, and automatically uses the required `--bypass-low-target-sdk-block` option on Android 14 or later.

After installation, open Camsung on the phone and enable its switch. Tap the lock icon to reapply the setting after each boot. The phone must be in Vibrate or Mute mode when using the silent-camera feature.

## Notes

- A system update may reset the setting.
- The change only applies where device firmware and local regulations permit it.
- On supported devices, Vibrate or Mute mode may still be required.
- Battery health and cycle fields may not be exposed by every model or firmware version.
