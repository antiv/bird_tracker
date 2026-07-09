# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app for bird watchers: record "transects" (survey routes) on a Google Map, drop markers for bird sightings with species data, export/share as KML/XLSX/JSON. Targets Android and iOS. Bundle IDs: `rs.antonijevic.bird_tracker` (Android), `rs.antonijevic.birdTracker` (iOS).

## Commands

Flutter is managed by **fvm** — plain `flutter` is not on PATH. Use `fvm flutter ...` (or `~/fvm/versions/stable/bin/flutter`).

```bash
fvm flutter pub get
fvm flutter run                 # dev run on connected device
fvm flutter analyze             # lint (flutter_lints defaults)
fvm flutter build ios --no-codesign   # verify iOS compiles
```

There is no test suite (`test/` does not exist).

### Release builds

- **Android**: `./build_release.sh [--bump]` — cleans, builds obfuscated appbundle, copies to `bird_tracker.aab` at repo root. `--bump` increments patch+build in pubspec.
- **iOS**: `./deploy_ios.sh` — full build + signed export + upload to App Store Connect via API key. **Bumps version by default**; use `--no-bump` if the version was already bumped, `--no-upload` to only produce the .ipa. Requires `ios/deploy.env` (see `ios/deploy.env.example`). The script patches the generated SPM `Package.swift` from iOS 13 → 14 (required by file_picker) before building — don't "fix" that seemingly redundant sed.

Version format in pubspec.yaml is `X.Y.Z+N`; both scripts bump patch and build number together. Apple requires a new build number for every App Store Connect upload.

## Configuration / secrets (not in git)

- **`.env` at repo root** — bundled as a Flutter asset and required at runtime (`main.dart` crashes without it). Keys: `MAPS_API_KEY` (+ optional `MAPS_API_KEY_ANDROID` / `MAPS_API_KEY_IOS` overrides), `PRIVACY_POLICY_URL`. Consumed in three places: Dart via flutter_dotenv, Android via `build.gradle.kts` → manifest placeholder `${mapsApiKey}`, iOS via `AppDelegate.swift` which parses the bundled asset at runtime.
- **`android/key.properties`** — release keystore config for Android signing.
- **`ios/deploy.env`** — App Store Connect API key credentials for deploy_ios.sh.

## Architecture

Single-screen app: `lib/home_page.dart` hosts the Google Map and drives everything else through dialogs/bottom sheets.

- **State**: `lib/service/data_service.dart` — a ChangeNotifier **singleton** exposed through `provider`; holds the active `Transect`, map controller/completer, map type, and SharedPreferences accessors. Widgets call `DataService()` directly (factory returns the singleton) and `notify()` to trigger rebuilds.
- **Persistence**: `lib/service/sembast_service.dart` — sembast NoSQL singleton with a single `transects` store. Models are **manually JSON-serialized** (`toJson`/`fromJson`, no codegen). This replaced Isar; JSON backup/restore lives here too.
- **Models** (`lib/model/`): `Transect` (route with start/end, name) → `points` (recorded track) + `markers` (`Placemark` sightings) → `Species` entries. `Transect` also owns KML/XLSX export logic. The species catalog is a hardcoded list in `lib/configuration/species.dart`.
- **UI helpers**: `lib/utils/ux_builder.dart` — global dialogs/snackbars/bottom sheets using `context_holder` (`ContextHolder.currentContext`), so no BuildContext threading. All user-facing strings go through easy_localization `.tr()`.
- **Location**: uses the `location` package (not geolocator/permission_handler). The permission + background-mode flow is in `lib/utils/location_helper.dart`: a custom pre-permission dialog (`showPermissionInfoDialog`) precedes the system prompt, then `enableBackgroundMode()`. The dialog text is **platform-specific** (`Platform.isIOS` in ux_builder.dart) because Android needs a two-step "Allow all the time" grant while iOS does not.

## Localization — keep three places in sync

1. **App strings**: easy_localization with `assets/translations/en.json` and `sr-Latn.json`; supported locales `en` and `sr-Latn`, fallback `en` (`lib/main.dart`). Any new UI string needs a key in **both** JSON files.
2. **iOS permission strings**: `ios/Runner/Info.plist` holds the English (default) `NSLocation*UsageDescription` values; localized overrides live in `ios/Runner/{en,sr-Latn,sr}.lproj/InfoPlist.strings` (registered as a variant group in project.pbxproj). If a permission string changes, update the plist **and all three** .strings files — Apple rejected the app once (Guideline 4) for permission prompts not matching the app's language.
3. **Android**: permission dialogs are system-provided; no strings to maintain.
