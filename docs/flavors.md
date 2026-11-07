# Flavors and application IDs

Two different things are often confused:

| Concept | What it is | Example |
|---|---|---|
| **Build mode** | How Flutter compiles: `debug`, `profile`, `release` | `flutter run --profile` |
| **Flavor** | Which environment the app targets (own app ID, name, backend) | `dev`, `staging`, `prod` |

Build modes are chosen per run. Flavors are configured natively (Android
`productFlavors`, iOS schemes and build configurations) and let several
variants be installed side by side on one phone, because each has a different
app ID.

| Flavor | Android application ID | iOS bundle ID | App name | Backend (`config/*.json`) |
|---|---|---|---|---|
| dev | `pl.dybcio.habit_focus.dev` | `pl.dybcio.habitFocus.dev` | Habit Focus DEV | local or dev server, HTTP allowed |
| staging | `pl.dybcio.habit_focus.staging` | `pl.dybcio.habitFocus.staging` | Habit Focus STG | HTTPS only |
| prod | `pl.dybcio.habit_focus` | `pl.dybcio.habitFocus` | Habit Focus | HTTPS only |

## Running

Always pass the flavor **and** its config file. The two must match:

```bash
fvm flutter run --flavor dev     --dart-define-from-file=config/dev.json
fvm flutter run --flavor staging --dart-define-from-file=config/staging.json
fvm flutter run --flavor prod    --dart-define-from-file=config/prod.json

fvm flutter build apk --release --flavor prod --dart-define-from-file=config/prod.json
```

Without `--flavor` the Android build fails (there is no default flavor on
purpose, so a prod build can never happen by accident). In VS Code or Android
Studio put `--flavor ... --dart-define-from-file=...` into the run
configuration, one per flavor.

## Dart side

`config/<flavor>.json` holds `FLAVOR` and `API_BASE_URL`. `AppConfig` reads them
at startup and rejects unsafe values (plain HTTP outside dev). These values are
compiled into the binary and are **not secret**.

## Android

Configured in `android/app/build.gradle.kts` (`productFlavors`): each flavor has
an `applicationIdSuffix` and an `app_name` resource used as the launcher label
(`android:label="@string/app_name"` in the manifest).

* `android/app/src/dev/AndroidManifest.xml` allows plain HTTP, for the dev
  flavor only.
* The `INTERNET` permission is declared in the main manifest. Without it a
  release build cannot reach the backend (debug builds get it from the debug
  manifest, which hides the problem).
* Release builds are still signed with the debug key. A real signing setup
  comes with the release workflow.

Check: `fvm flutter build apk --debug --flavor dev
--dart-define-from-file=config/dev.json`. CI builds this on every pull request.

## iOS

Flavors on iOS need three things: build configurations named
`<Mode>-<flavor>` (for example `Debug-dev`), a scheme named exactly like the
flavor, and a CocoaPods mapping for the new configurations. Doing that by hand
in Xcode is slow and easy to get wrong, so `tool/ios_flavors.rb` does it for
all three flavors. It is safe to run again.

One-time setup, from the repository root on a Mac:

```bash
fvm flutter build ios --config-only --no-codesign   # creates ios/Podfile
ruby tool/ios_flavors.rb
cd ios && pod install && cd ..
```

What it changes: `ios/Runner.xcodeproj/project.pbxproj` (configurations,
bundle ID suffix, `APP_DISPLAY_NAME`), new shared schemes `dev`, `staging`,
`prod`, and `ios/Podfile` (the `project 'Runner', {...}` mapping).
`Info.plist` reads the app name from `$(APP_DISPLAY_NAME)`. Review the diff
before committing, and if anything looks wrong, `git checkout ios/` undoes it.

If the script says `cannot load such file -- xcodeproj`, the gem is not visible
to your Ruby. Install it for your user (`gem install --user-install xcodeproj`)
or run the script with the Ruby that ships with CocoaPods.

Check: `fvm flutter run --flavor dev --dart-define-from-file=config/dev.json`
on a simulator or an iPhone.

### Signing on a real iPhone

Each flavor is a separate App ID, so Xcode has to create a provisioning profile
for each (`...dev`, `...staging`, `...`). Select the team for every
configuration of the `Runner` target once (*Signing & Capabilities*). A free
Apple ID allows a limited number of new App IDs per week and the profiles
expire after 7 days; run the app again to renew them.

### Manual alternative

If you prefer Xcode: duplicate the configurations `Debug`, `Release`,
`Profile` as `Debug-dev`, `Release-dev`, `Profile-dev` (and for `staging`,
`prod`), duplicate the `Runner` scheme once per flavor and point each action to
the matching configuration, set `PRODUCT_BUNDLE_IDENTIFIER` and
`APP_DISPLAY_NAME` per configuration, and add the mapping to `ios/Podfile`:

```ruby
project 'Runner', {
  'Debug' => :debug, 'Profile' => :release, 'Release' => :release,
  'Debug-dev' => :debug, 'Profile-dev' => :release, 'Release-dev' => :release,
  # ... the same for staging and prod
}
```

## Adding a flavor

1. `config/<name>.json`.
2. A `create("<name>")` block in `productFlavors`.
3. An entry in `FLAVORS` in `tool/ios_flavors.rb`, then run the script.
4. A row in the table above.

## Later

- Different launcher icons per flavor, so testers see which build they hold.
- Separate Sentry/Crashlytics projects per flavor if added.
- Release workflow: builds `--flavor prod` with `--obfuscate
  --split-debug-info` and signs with keys from GitHub secrets.
