# Blaze Hosting app

Package: `com.blazenxt.hosting`  
Version: **1.0.0**  
Panel: https://panel.nawazfx.com  

Isolated client: the WebView only loads `*.nawazfx.com`. It cannot open other sites. Each install keeps its own cookies — one Blaze account, that user’s servers only.

## In-app update (Firebase Remote Config)

On launch the app reads Firebase Remote Config, compares `package_info` with the platform key, and if newer (or below `min_*`) shows **Update now**. That button downloads the package and runs the native installer.

| Platform | Remote keys | Install |
| --- | --- | --- |
| Android | `latest_android_version` `android_url` `min_android_version` | Download APK → system package installer (`REQUEST_INSTALL_PACKAGES`) |
| Windows | `latest_windows_version` `windows_url` | Download Inno Setup `.exe` → `/VERYSILENT /CLOSEAPPLICATIONS` |
| macOS | `latest_mac_version` `mac_url` | Download `.pkg` → `open` |
| Linux | `latest_linux_version` `linux_url` | AppImage exec or `pkexec dpkg -i` |
| iOS | `latest_ios_version` `ios_url` | Opens URL (no sideload) |

Also used:

- `panel_url` — default `https://panel.nawazfx.com`
- `maintenance_message` — banner, empty = off
- `android_notes` / `windows_notes` / … — optional changelog in the dialog

### One-time Firebase

1. Firebase Console → add Android app **com.blazenxt.hosting**, iOS bundle `com.blazenxt.hosting`, plus macOS/Windows if you use those.
2. Download `google-services.json` → `android/app/google-services.json`
3. Download `GoogleService-Info.plist` → `ios/Runner/` (and macos if needed)
4. From this folder: `dart pub global activate flutterfire_cli && flutterfire configure`
5. Remote Config → add the keys above (defaults already match 1.0.0 so the first build does not force-update itself).
6. Publish Remote Config.

Without those files the app still opens the panel; updates stay off until Firebase initializes.

## GitHub Actions

`.github/workflows/build.yml` builds Android APK, Windows, Linux, macOS. Put `google-services.json` in the repo **or** add it as a GitHub Actions secret written to disk before `flutter build apk`.

Windows silent installer: compile `installer/blaze-hosting.iss` with Inno Setup after `flutter build windows`.
