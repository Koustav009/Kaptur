# Kaptur — Project Agent Guide

Kaptur is a **FotoOwl clone**: a photo/event sharing platform where photographers create **events** (galleries) and clients view photos from those events. It consists of two codebases in this workspace:

| Folder | Stack | Role |
|---|---|---|
| `Kaptur/` | Flutter 3.41.7 (FVM), Dart ^3.9.2, GetX | Android client app |
| `Kaptur-backend/` | Spring Boot 4.0.5, Java 21, Maven | REST API (metadata only — file bytes go to external TUSd/S3) |

---

## 1. What the project is

- Users sign up / log in (email + Google), create **events** (galleries with title, description, date, location).
- Event members upload **photos** via resumable **TUS** uploads.
- Architecture: Flutter app → Spring Boot REST API (PostgreSQL, JWT auth) → TUSd (Go) upload server → S3 storage.
- Target platform is Android (`com.koustav.kaptur`, Firebase configured for Google Sign-In).

## 2. What is done so far

### Backend (`Kaptur-backend/`)
- **Auth**: `POST /auth/register`, `/auth/login`, `/auth/google` (Google ID-token verification), `/auth/refresh` (DB-backed refresh tokens, 30d; access JWT 15 min, HS256).
- **Events**: full CRUD with soft delete; creator auto-added as ADMIN member.
- **Photos (metadata)**: upload init (`POST /events/{id}/photos/init`), listing, soft delete.
- **TUS integration**: `/tusd/hooks` webhooks (pre-create → override upload ID, post-finish → store S3 key + `COMPLETED`, post-terminate → `FAILED`). Downloads served by TUSd at `{tusd.base-url}/{photoId}`.
- **Security**: stateless JWT filter, role claim from DB on refresh; Swagger at `/swagger-ui/index.html`.
- **DB**: PostgreSQL (`kaptur`, schema `kaptur_schema`), `ddl-auto=update`; schema fully migrated to UUID keys (legacy `bigint` drift on `events`/`event_photos`/`user_role_mst` fixed 2026-09); legacy unmapped tables dropped; manual seeding of `USER_ROLE_MST` required.
- **Logging**: leveled config in `application.properties`; `@Slf4j` leveled logs across controllers/services.
- Tests: service + controller tests for auth, events, files (62 tests, all passing).

### Flutter app (`Kaptur/`)
- **GetX modular MVC** (`modules/*/bindings,controllers,views`), routes: `/splash`, `/login`, `/signup`, `/home`.
- **Splash** → auto-login based on session; **Login / Signup** screens with animations; **Google Sign-In v7** (ID token → `/auth/google`).
- **Home dashboard**: stats (events, photos, storage), adaptive event grid, pull-to-refresh; right-side drawer with user photo/name/email + logout (confirmation dialog).
- **Event CRUD** from the dashboard (create/edit/delete dialogs) wired to backend; failures surface as error snackbars + logs — no mock/offline fallback data.
- **Session layer**: JWT + refresh token in secure storage; flat `AuthResponse` (`{accessToken, refreshToken, kptId, email, name, imageUrl, role}` — no nested `user`) parsed by `AuthController._persistSession`, so sessions survive hot restart/app relaunch until the refresh token expires/revokes; `ApiClient` auto-refreshes on 401 (deduped) then retries.
- **Theming**: Material 3 light/dark (violet/teal), persisted, follows system.
- **Responsive UI** (all screen types): scroll bodies wrapped in `lib/widgets/responsive_center.dart` (`ResponsiveCenter`, auth 480px / dashboard 1100px max width); event list is an adaptive `SliverGridDelegateWithMaxCrossAxisExtent` grid. Applies to every NEW screen too.
- **Flavors (dev/prod)**: entrypoints `lib/main_dev.dart` / `lib/main_prod.dart` → shared `bootstrap()` in `lib/main.dart`; flavor + config in `lib/core/config/app_config.dart`.
  - Base URL: `--dart-define=BASE_URL` override → prod placeholder (`https://api.kaptur.app`) → dev: `localhost:8080` on web, `10.0.2.2:8080` on Android emulator.
  - Run: `flutter run --flavor dev -t lib/main_dev.dart` (VS Code: `.vscode/launch.json`). Android Gradle flavors in `android/app/build.gradle.kts` set the display name via `resValue("string", "app_name")` → manifest `@string/app_name`.
  - Do NOT add an Android `applicationIdSuffix` for dev — Firebase/Google Sign-In OAuth client is registered for `com.koustav.kaptur`.
  - Per-flavor logos/splash (when added): `android/app/src/{dev,prod}/res/` via flutter_launcher_icons / flutter_native_splash.

## 3. What is coming (roadmap / gaps)

### Flutter app
- **Photo gallery & viewer** — the core of the product: event detail screen, photo grid, full-screen viewer, download. Event tiles currently don't navigate anywhere.
- **Photo upload** from the app (TUS resumable upload flow against TUSd, using `/photos/init`).
- **Camera** capture (icons exist but are decorative).
- **Sharing** event links/photos.
- **Subscriptions / payments** (no backend support yet either).
- Fixes: release `INTERNET` permission + network security config, form validation, real test suite, remove unused `dio`, per-flavor app icons/splash.

### Backend
- **Member invitation flow** (add members to events; `EventMembersHistory`, `EventRole` exist but unused; no invite endpoints).
- **Role-based authorization** (`@PreAuthorize` / membership checks; `getEventById` currently readable by any authenticated user).
- **Image processing pipeline** (thumbnails/previews — none today; clients get full originals).
- **Payment/subscription/quota** module (nothing exists).
- **S3 cleanup** on photo delete (currently orphaned objects).
- Hardening: secrets out of `application.properties`, authenticated TUSd hooks, proper exception→status mapping, pagination, Flyway migrations.

## 4. Conventions

- Flutter: GetX everywhere (state, routing, DI, snackbars); layered `lib/core`, `lib/data`, `lib/modules`; codegen via `json_serializable` + `build_runner`.
- Backend: Lombok, UUIDv7 PKs (`kptId`, `evntId`), soft deletes, DTO-less simple entities, tests with JUnit/Mockito.
- The two apps communicate over the `/auth`, `/events`, `/events/{id}/photos/**`, `/tusd/hooks` REST surface (see Swagger).

## 5. Rules (learned from past sessions — follow for ALL new work)

- **Every screen must be dynamic and responsive for all screen types** (phone, tablet, web/desktop): wrap scroll bodies in `ResponsiveCenter` and use adaptive layouts (max-cross-axis-extent grids) — never fixed mobile-only dimensions.
- **Never silently mask backend/network failures** with mock or "Offline Mode" fallback data — surface real errors via error snackbars + leveled logs.
- Logout/destructive actions always confirm with a dialog first.
- Every method carries leveled logging: DEBUG for method entry/exit details, INFO for state-changing operations, WARN for recoverable/unauthorized attempts, ERROR with exception + stack trace for failures.
- The backend `AuthResponse` is **flat** (`{accessToken, refreshToken, kptId, email, name, imageUrl, role}`) — no nested `user`; sessions must survive app restarts until the refresh token expires/revokes.
- Backend entities use UUID PKs and `ddl-auto=update` cannot alter column types — explicit DB migration is required when entity types change; `USER_ROLE_MST` must be seeded manually.
