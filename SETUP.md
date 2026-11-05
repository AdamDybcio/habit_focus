# Setup (one time, on your Mac)

Run everything from the root of the project folder.

## 1. Create the project folder and pin Flutter with FVM

```bash
mkdir habit_focus && cd habit_focus
git init
fvm install stable
fvm use stable --pin      # writes .fvmrc with an exact version and creates .fvm/
fvm flutter --version
```

`--pin` matters: CI reads the exact version from `.fvmrc`. If your FVM version
does not know `--pin`, run `fvm releases`, pick the newest stable number and run
`fvm use <number>`. Commit `.fvmrc`, ignore `.fvm/`.

VS Code: set `"dart.flutterSdkPath": ".fvm/flutter_sdk"` in `.vscode/settings.json`.

## 2. Generate the Flutter project

```bash
fvm flutter create --org com.example --project-name habit_focus --platforms android,ios .
```

Replace `com.example` with your own reverse-domain. The project name must stay
`habit_focus`, because all imports are `package:habit_focus/...`.

Append to the generated `.gitignore`:

```
.fvm/
coverage/
```

## 3. Unzip our files over the project

Unzip `habit_focus-step-1.zip` into the project root and let it **overwrite**
existing files (`analysis_options.yaml`, `lib/main.dart`, `README.md`). Then delete
the generated template test:

```bash
rm test/widget_test.dart
```

## 4. Add packages (the tool picks the latest versions)

```bash
fvm flutter pub add material_ui flutter_bloc go_router dio flutter_secure_storage get_it equatable intl
fvm flutter pub add flutter_localizations --sdk=flutter
fvm flutter pub add drift drift_flutter
fvm flutter pub add dev:very_good_analysis dev:bloc_test dev:mocktail dev:drift_dev dev:build_runner
```

If `intl` conflicts with `flutter_localizations`, run `fvm flutter pub add intl:any`
instead. Do not edit
versions by hand.

## 5. Enable localization generation

In `pubspec.yaml`, under the `flutter:` section, add:

```yaml
flutter:
  generate: true
```

(`uses-material-design: true` can stay next to it.) Then:

```bash
fvm flutter pub get       # also generates lib/l10n/generated/
```

Commit the generated files in `lib/l10n/generated/`.

## 6. Format, analyze, test

```bash
fvm dart format lib test
fvm flutter analyze
fvm flutter test
```

## 7. Run

```bash
fvm flutter run --dart-define-from-file=config/dev.json
```

Without native flavors set up (see `docs/flavors.md`) do not pass `--flavor` yet.
