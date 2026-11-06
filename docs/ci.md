# CI/CD

## Workflow `CI` (`.github/workflows/ci.yaml`)

Runs on every pull request, on every push to `main` and manually
(*Actions → CI → Run workflow*). Steps, in order:

1. Flutter version is read from `.fvmrc`, so CI always matches local FVM.
2. `flutter pub get`
3. `dart format --set-exit-if-changed` on `lib/main.dart lib/app lib/core
   lib/features test` (generated code in `lib/l10n/generated` is excluded).
4. `flutter analyze` (very_good_analysis, warnings fail the build).
5. `flutter test --coverage`; `coverage/lcov.info` is uploaded as an artifact.

Integration tests (Maestro, device tests) are **not** part of this workflow,
they need a device and run locally.

## Run the same checks locally

```bash
fvm dart format lib/main.dart lib/app lib/core lib/features test
fvm flutter analyze
fvm flutter test
```

## Branching and merging

* Work on a short-lived branch (`feat/...`, `fix/...`, `chore/...`).
* Small commits, push often, open a pull request early: CI runs on the PR.
* Merge only when CI is green. In GitHub, *Settings → Branches → Branch
  protection rule* for `main`: require a pull request and the status check
  `analyze-and-test`.

## Dependabot

`.github/dependabot.yml` opens weekly PRs for pub packages and GitHub
Actions. CI validates each of them; merge when green.

## Planned

* Android debug build (per flavor) once native flavors exist.
* Release workflow: signed APK attached to a GitHub Release on a `v*` tag.
