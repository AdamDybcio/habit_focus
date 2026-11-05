# AGENTS.md

Instructions for AI coding agents (and humans) working in this repository.
Read this file fully before changing code. Details live in `docs/`.

## Project

`habit_focus` – a habit tracker with a focus mode (hold-to-check with haptics,
phone-face-down focus sessions detected via sensors, animated progress visual,
offline-first sync with a Symfony backend). Mobile only: Android and iOS.
The backend lives in a separate repository.

## Toolchain

- Flutter is managed with **FVM**. The pinned version is in `.fvmrc` (committed).
  Always run `fvm flutter ...` and `fvm dart ...`, never the global `flutter`.
- Lints: `very_good_analysis` (see `analysis_options.yaml`). `fvm flutter analyze`
  must finish with **zero** issues. Do not add `// ignore:` without a comment
  explaining why.
- Before adding any package: check the latest version on pub.dev and add it with
  `fvm flutter pub add <name>` (never hand-write a version from memory). Prefer
  well-maintained, widely used packages and avoid abandoned ones.
- Flavors: `dev`, `staging`, `prod` (different application IDs). Run with
  `--flavor <name> --dart-define-from-file=config/<name>.json`.
  `--dart-define` values are NOT secret: never put keys or secrets in them.
  Build-time values are read once through `AppConfig` (`core/config`); never
  call `String.fromEnvironment` elsewhere. Native setup is in `docs/flavors.md`.

## Material imports (important, easy to get wrong)

Since Flutter 3.47 Material and Cupertino are standalone packages. Many models
still emit the old imports. In this repo:

- Use `import 'package:material_ui/material_ui.dart';`
- Never use `package:flutter/material.dart` or `package:flutter/cupertino.dart`.
- Localization delegates for Material come from `material_ui`
  (`GlobalMaterialLocalizations.delegates`); do not duplicate them from
  `flutter_localizations`.
- Pure widget-layer code may import `package:flutter/widgets.dart`.

## Architecture: Clean Architecture, feature-first

```
lib/
  app/                 # app widget, router, DI bootstrap
  core/                # shared: config (flavors), errors, Result, theme tokens,
                       # shared widgets (core/ui), network, storage, utils
  features/
    <feature>/
      domain/          # pure Dart, NO Flutter or package imports except meta/equatable
        entities/
        repositories/  # abstract interfaces
        usecases/
      data/
        datasources/   # remote (Dio) and local (Drift, secure storage)
        models/        # DTOs, JSON and DB mapping
        repositories/  # implementations of domain interfaces
      presentation/
        bloc/          # BLoC or Cubit, events and states
        pages/         # one screen = one file
        widgets/       # reusable widgets of this feature
  l10n/
```

Dependency rule: `presentation -> domain <- data`. `domain` depends on nothing.
`presentation` never imports from `data`. Wiring happens only in DI (`get_it`)
inside `app/` and per-feature `di.dart`.

### Rules

1. **One widget class per file.** File name equals the class name in snake_case.
   No private `_Widget` classes in the same file, and no helper methods that
   return widgets. Extract a real widget class instead.
2. Widgets are `const` wherever possible. Business logic never lives in widgets.
3. Entities are immutable (`final` fields, `copyWith`, value equality).
   DTOs are mapped to entities in the data layer; DTOs never leak upward.
4. Repositories return `Result<T>` (sealed type with `Success` and `Failure`).
   Do not throw across layer boundaries. Datasources may throw; repository
   implementations catch and map to typed `Failure`s.
5. BLoC states are sealed classes or a single immutable state with status enum.
   Events and states are in their own files. UI uses `BlocBuilder`/`BlocListener`
   with `buildWhen`/`listenWhen` where it avoids needless rebuilds.
6. Every public member has a doc comment (required by the lint set).
7. No hard-coded user-facing strings: use `AppLocalizations` (Polish and English).
8. No hard-coded colors, text styles or spacing in widgets: use the theme and
   design tokens (see `docs/ui-guidelines.md`).
9. Navigation only through `go_router`; route names are constants.
10. Network only through the shared Dio client in `core/network`.

### Example: repository pattern

```dart
// domain/repositories/habit_repository.dart
/// Source of truth for habits.
abstract interface class HabitRepository {
  /// Emits the current habits and every later change (offline-first).
  Stream<List<Habit>> watchHabits();

  /// Creates a habit locally and queues it for sync.
  Future<Result<Habit>> createHabit(NewHabit habit);
}
```

```dart
// data/repositories/habit_repository_impl.dart
/// Offline-first implementation backed by [HabitLocalDataSource] and
/// [HabitRemoteDataSource].
class HabitRepositoryImpl implements HabitRepository {
  /// Creates the repository.
  const HabitRepositoryImpl(this._local, this._remote);

  final HabitLocalDataSource _local;
  final HabitRemoteDataSource _remote;

  @override
  Stream<List<Habit>> watchHabits() =>
      _local.watchHabits().map((rows) => rows.map((r) => r.toEntity()).toList());

  @override
  Future<Result<Habit>> createHabit(NewHabit habit) async {
    try {
      final saved = await _local.insert(habit.toRow());
      return Success(saved.toEntity());
    } on LocalStorageException catch (e) {
      return Failure(StorageFailure(e.message));
    }
  }
}
```

## Auth and tokens

- Access token (short-lived) and refresh token (long-lived) are stored ONLY in
  `flutter_secure_storage` (Keychain on iOS, Keystore-backed storage on Android).
- `path_provider` only returns directory paths; files there are plain, not
  secret storage. Never store tokens in files, `SharedPreferences` or the DB.
- A Dio interceptor attaches the access token. On `401` it performs ONE refresh
  (guarded by a lock/queue so concurrent requests wait for the same refresh),
  then retries the original request. If refresh fails, clear tokens and route
  to login.

## Local data

Drift (SQLite) is the local database. Do not use Hive (the original is no
longer maintained). Key-value settings go to `shared_preferences`.

## Native bridges

Platform code lives in `android/` (Kotlin) and `ios/` (Swift). Prefer typed
bridges (Pigeon) for anything non-trivial; `MethodChannel`/`EventChannel` for
simple cases. Every channel name and method is documented in
`docs/native-bridges.md` and wrapped by a Dart interface in `domain/` so it can
be faked in tests.

## Security rules (OWASP MASVS / Mobile Top 10)

- No secrets, keys or passwords in the repo or in the app binary.
- HTTPS only; certificate pinning for the production API host.
- Validate all external input (API data, deep links, user input).
- No tokens, PII or request bodies in logs. Logging is off in release builds.
- Release builds use `--obfuscate --split-debug-info`.
- Sensitive screens block screenshots where the platform supports it.
- Dependencies are kept current (Dependabot); review new packages before adding.

## Testing (details in `docs/testing.md`)

- Every use case, repository, BLoC and mapper has unit tests (`mocktail`, `bloc_test`).
- Every reusable widget has a widget test; key screens have widget tests with
  fakes for BLoCs.
- Critical user flows have integration tests (`integration_test`); some device
  flows may also be covered with Maestro.
- Run before every commit: `fvm dart format lib test`, `fvm flutter analyze`
  and `fvm flutter test` (CI enforces all three).
- Do not mark a task done while tests fail or analysis reports issues.

## Workflow

- Branch per task, conventional commits (`feat:`, `fix:`, `refactor:`, `test:`,
  `docs:`, `chore:`), small PRs. CI (analyze, test, build) must pass.
- When you add a rule-worthy pattern or decision, update this file or `docs/`.
- If a request conflicts with this file, say so and ask instead of silently
  deviating.
