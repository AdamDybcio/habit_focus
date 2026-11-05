# Testing

## Pyramid

| Level | Tooling | What it covers | Share |
|---|---|---|---|
| Unit | `flutter_test`, `mocktail`, `bloc_test` | use cases, mappers, repositories, BLoCs, interceptors | most |
| Widget | `flutter_test` | one widget or screen with faked BLoCs/services | many |
| Integration | `integration_test` | real app flows on emulator/device (login, create habit, sync) | few |
| Device E2E | Maestro (YAML flows) | black-box flows incl. native dialogs; can run in the cloud on many devices | few |

Integration tests are not run in CI initially (slow, need emulator); they run
locally and optionally in a dedicated workflow.

## Conventions

- Mirror `lib/` under `test/`; file `foo.dart` has `foo_test.dart`.
- Arrange / Act / Assert, one behavior per test, descriptive names.
- Fakes and mocks via `mocktail`; shared test data in `test/helpers/`.
- BLoCs: test with `blocTest` (initial state, each event, error paths).
- Token refresh interceptor: test concurrent 401s trigger exactly one refresh.
- Widgets: pump with the real theme and localizations, in light and dark where
  it matters. Use `Semantics` finders to verify accessibility labels.
- No network or real storage in unit/widget tests.

## Coverage

Run `fvm flutter test --coverage`. Target: domain and data layers close to full
coverage; presentation covered by widget tests for all reusable widgets and
main screens. Coverage is a signal, not a goal: meaningful assertions first.

## Commands

```bash
fvm flutter analyze
fvm flutter test
fvm flutter test --coverage
fvm flutter test integration_test --flavor dev   # needs a device/emulator
maestro test .maestro/                           # device flows
```
