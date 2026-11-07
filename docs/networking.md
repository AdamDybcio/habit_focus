# Networking and authentication

## Backend contract

The app expects these endpoints (relative to `API_BASE_URL`). All bodies are
JSON.

| Endpoint | Request | Success response | Errors |
|---|---|---|---|
| `POST /auth/login` | `{"email": "...", "password": "..."}` | `200` `{"accessToken": "...", "refreshToken": "..."}` | `401` wrong credentials, `400`/`422` invalid input, `429` rate limited |
| `POST /auth/register` | `{"email": "...", "password": "..."}` (password 10 to 128 characters) | `201` `{"accessToken": "...", "refreshToken": "..."}` | `409` email already registered, `422` invalid input, `429` rate limited |
| `POST /auth/refresh` | `{"refreshToken": "..."}` | `200` new `{"accessToken": "...", "refreshToken": "..."}` | `401` (or `400`/`403`) refresh token invalid, expired or already used |
| `POST /auth/logout` | `{"refreshToken": "..."}` | `204`, also for unknown tokens | `429` rate limited |
| any other endpoint | header `Authorization: Bearer <accessToken>` | endpoint specific | `401` access token missing or expired |

Refresh tokens are **rotated**: every refresh returns a new pair and
invalidates the old refresh token. Using an old refresh token again ends the
whole session on the server.

The backend lives in
[habit-focus-api](https://github.com/AdamDybcio/habit-focus-api); its
`docs/api.md` is the reference for the contract. `API_BASE_URL` is the bare
host (for example `https://habit-api.dybcio.dev`), paths are not prefixed with
`/api`.

## Logout

Logout clears the tokens on the device first, so it works offline and never
blocks the UI. It then asks the server to revoke the refresh token as a best
effort request. If that request fails, the unused refresh token simply
expires on the server.

## Token flow

1. Login stores both tokens in `flutter_secure_storage` (Keychain on iOS,
   Keystore-backed storage on Android). `path_provider` only returns folder
   paths and its files are plain, so it is never used for secrets.
2. `AuthInterceptor` adds `Authorization: Bearer <accessToken>` to every
   request except those marked public (`AuthInterceptor.skipAuthKey`).
3. When a request fails with `401`:
   - if the stored access token differs from the one the request was sent
     with, another request has already refreshed the tokens, so the request is
     simply retried;
   - otherwise one refresh is started. Requests that fail meanwhile wait for
     the same refresh instead of starting their own (the backend would reject
     the second use of a rotated refresh token and log the user out);
   - after a successful refresh the new pair is stored and the failed request
     is retried once. A retried request is never refreshed again, so there is
     no loop.
4. If the backend rejects the refresh token (`400`/`401`/`403`), the tokens
   are removed and `SessionEvents.expired` fires. `SessionCubit` then switches
   to the signed-out state and `go_router` redirects to the login screen.
5. Network errors and `5xx` during refresh do **not** log the user out: the
   original error is returned and the session stays, so the next request can
   try again.

## Source layout

| Path | Responsibility |
|---|---|
| `lib/core/auth/` | `AuthTokens`, `TokenStorage` and its secure implementation, `SessionEvents` |
| `lib/core/network/` | Dio factory, `AuthInterceptor`, token refresher, failure mapping |
| `lib/features/auth/` | login use cases, repository, `SessionCubit`, `LoginCubit`, login screen |
| `lib/app/router/` | redirect rules based on the session |

## Local development over plain HTTP

Release builds must use HTTPS (`AppConfig` rejects `http` for `staging` and
`prod`). Only `dev` may use plain HTTP, and mobile platforms block it by
default.

**Android (dev flavor only).** `android/app/src/dev/AndroidManifest.xml`
sets `usesCleartextTraffic="true"` and is merged only into the `dev` flavor, so
`staging` and `prod` stay HTTPS-only. The Android emulator reaches the host
machine at `10.0.2.2`.

The main manifest declares the `INTERNET` permission. Debug and profile
manifests have their own copy for tooling, but release builds only work with
the one in the main manifest.

**iOS.** App Transport Security blocks plain HTTP to servers on the network.
The simplest way to avoid weakening the app is to run the dev backend behind
HTTPS (for example the Caddy instance on the VM) and put that address in
`config/dev.json`. If you must use HTTP locally, add
`NSAppTransportSecurity` with `NSAllowsLocalNetworking` to `Info.plist` for
development builds only.

## Platform notes

- `flutter_secure_storage` may require a higher Android `minSdk` than the
  Flutter default (its README lists the current value). If the build complains,
  set `minSdk` in `android/app/build.gradle.kts` accordingly.
- Hardening planned for later steps: certificate pinning for the production
  host, `FLAG_SECURE` on sensitive screens, biometric unlock of the session.

## Security checklist for network code

- Never log request or response bodies or headers (they hold tokens and
  personal data). `createApiDio` logs request lines and status codes only, and
  not at all in production.
- Never put tokens, passwords or API keys in `config/*.json` or
  `--dart-define`: they end up in the binary.
- Error messages produced by the app must not contain token values.
- Treat every server response as untrusted: parse and validate it
  (`parseAuthTokens`) before using it.
