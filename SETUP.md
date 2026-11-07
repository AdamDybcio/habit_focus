# Setup

How to build and run `habit_focus` from a fresh clone.

## Prerequisites

| Tool | Needed for | Notes |
|---|---|---|
| [Git](https://git-scm.com) | cloning | |
| [FVM](https://fvm.app) | pinning the Flutter version | The exact version is in `.fvmrc` |
| Android Studio (SDK + emulator) | Android | Or a physical device with USB debugging |
| Xcode and CocoaPods | iOS (macOS only) | Free Apple ID is enough for your own device |
| A running backend | login and sync | Separate repository, see [Backend](#backend) |

You do not need to install Flutter yourself: FVM downloads the pinned version.

## 1. Get the code and the Flutter version

```bash
git clone <repository-url>
cd habit_focus
fvm install          # installs the version from .fvmrc
fvm flutter --version
```

Always use `fvm flutter ...` and `fvm dart ...` in this project, never a global
`flutter`. Optional: in VS Code set `"dart.flutterSdkPath": ".fvm/flutter_sdk"`
in `.vscode/settings.json`.

## 2. Install dependencies

```bash
fvm flutter pub get
```

This also generates the localization code (Polish and English) from
`lib/l10n/arb/`.

## 3. Configure the environment

Build-time settings live in `config/<flavor>.json`:

```json
{
  "FLAVOR": "dev",
  "API_BASE_URL": "http://10.0.2.2:8000"
}
```

- `FLAVOR` is one of `dev`, `staging`, `prod`.
- `API_BASE_URL` is the backend address. Plain `http` is accepted only for
  `dev`; `staging` and `prod` require `https`.
- Pick the host that matches where the app runs:

| Where the app runs | Host for a backend on your computer |
|---|---|
| Android emulator | `10.0.2.2` |
| iOS simulator | `localhost` |
| Physical device | your computer's LAN IP (same Wi-Fi) |

These values are compiled into the app and are visible to anyone who unpacks
it. Never put secrets in them.

## 4. Run

```bash
fvm flutter run --flavor dev --dart-define-from-file=config/dev.json
```

Always pass both `--flavor` and the matching `--dart-define-from-file`. The
flavors give each environment its own app ID and name, so `dev`, `staging` and
`prod` can be installed side by side. Details, including the one-time iOS
setup, are in [`docs/flavors.md`](docs/flavors.md).

### iOS on a physical device

1. `open ios/Runner.xcworkspace`, select the `Runner` target, tab *Signing &
   Capabilities*.
2. Choose your Apple ID as the team and set a unique bundle identifier for the
   `Runner` target in each configuration (`dev`, `staging`, `prod` use a
   suffix, see `docs/flavors.md`).
3. Run from Xcode once, then `fvm flutter run --flavor dev
   --dart-define-from-file=config/dev.json` works.

With a free Apple ID the provisioning profile expires after 7 days; run the
app again to renew it. Distribution through TestFlight or the App Store needs
a paid Apple Developer account.

## 5. Check the code

```bash
fvm dart format lib test
fvm flutter analyze
fvm flutter test
```

CI runs the same checks on every push and pull request.

## 6. Build an APK

```bash
fvm flutter build apk --release \
  --dart-define-from-file=config/prod.json \
  --obfuscate --split-debug-info=build/symbols
```

Release signing needs your own keystore. Keep the keystore and
`key.properties` out of git.

## Backend

The app talks to a REST API implemented in a separate Symfony repository
(JWT access token plus rotating refresh token). Start it locally or deploy it,
then point `API_BASE_URL` at it.

## Troubleshooting

| Problem | Fix |
|---|---|
| `requires SDK version ^x.y.z` during `pub get` | Your Flutter is older than the project. Run `fvm install` and use `fvm flutter`, not the global `flutter`. |
| `fvm: command not found` | Install FVM, see [fvm.app](https://fvm.app). |
| `Unknown FLAVOR` or `API_BASE_URL is missing` at startup | Run with `--dart-define-from-file=config/<flavor>.json`. |
| `AppLocalizations` not found | Run `fvm flutter pub get`; check that `generate: true` is set under `flutter:` in `pubspec.yaml`. |
| Android emulator cannot reach the backend | Use `10.0.2.2` instead of `localhost`. |
| iOS build fails with signing errors | Set a team and a unique bundle identifier in Xcode. |
| Stale build state | `fvm flutter clean && fvm flutter pub get` |
