# Flavors and application IDs

Two different things are often confused:

| Concept | What it is | Example |
|---|---|---|
| **Build mode** | How Flutter compiles: `debug`, `profile`, `release` | `flutter run --profile` |
| **Flavor** | Which environment the app targets (own app ID, name, icon, backend) | `dev`, `staging`, `prod` |

Build modes are chosen per run. Flavors are configured natively (Android
`productFlavors`, iOS schemes + build configurations) and let several variants
be installed side by side on one phone because each has a different app ID.

| Flavor | Android application ID | iOS bundle ID | App name |
|---|---|---|---|
| dev | `<org>.habit_focus.dev` | `<org>.habitFocus.dev` | Habit Focus DEV |
| staging | `<org>.habit_focus.staging` | `<org>.habitFocus.staging` | Habit Focus STG |
| prod | `<org>.habit_focus` | `<org>.habitFocus` | Habit Focus |

Replace `<org>` with the reverse-domain used in `flutter create --org`.

## Dart side (already in the repo)

`config/<flavor>.json` holds `FLAVOR` and `API_BASE_URL`. `AppConfig` reads them
at startup and rejects unsafe values (plain HTTP outside dev). Run with:

```bash
fvm flutter run --flavor dev --dart-define-from-file=config/dev.json
```

These values are compiled into the binary and are **not secret**.

## Android (`android/app/build.gradle.kts`)

Inside the `android { ... }` block add (Kotlin DSL; adjust if your template
still uses Groovy):

```kotlin
flavorDimensions += "env"
productFlavors {
    create("dev") {
        dimension = "env"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "Habit Focus DEV")
    }
    create("staging") {
        dimension = "env"
        applicationIdSuffix = ".staging"
        resValue("string", "app_name", "Habit Focus STG")
    }
    create("prod") {
        dimension = "env"
        resValue("string", "app_name", "Habit Focus")
    }
}
```

In `android/app/src/main/AndroidManifest.xml` set
`android:label="@string/app_name"` on the `<application>` element.

Optional: a different ID for debug builds of one flavor is done with a build
type suffix:

```kotlin
buildTypes {
    debug {
        applicationIdSuffix = ".debug"
    }
}
```

Check the result: `fvm flutter build apk --debug --flavor dev
--dart-define-from-file=config/dev.json`.

## iOS (Xcode)

Follow the official Flutter guide "Set up Flutter flavors for iOS and macOS"
(docs.flutter.dev) and keep these rules:

1. In Xcode create one build configuration per mode and flavor, named
   `Debug-dev`, `Release-dev`, `Profile-dev`, and the same for `staging`, `prod`
   (duplicate the existing Debug/Release/Profile configurations).
2. Create one scheme per flavor, named exactly like the flavor (`dev`,
   `staging`, `prod`), pointing each action to the matching configuration.
3. Per configuration set `PRODUCT_BUNDLE_IDENTIFIER` and the display name
   (`PRODUCT_NAME` / `CFBundleDisplayName`) using an `.xcconfig` file or build
   settings.
4. Run with `fvm flutter run --flavor dev --dart-define-from-file=config/dev.json`.

The `flutter_flavorizr` package can automate both platforms. Check its current
state on pub.dev before using it and review the generated changes.

## Per-flavor extras (later steps)

- Different launcher icons per flavor so testers see which build they hold.
- Separate Firebase/Crashlytics/Sentry projects per flavor if added.
- CI release workflow builds `--flavor prod` with `--obfuscate
  --split-debug-info` and signs with keys from GitHub secrets.
