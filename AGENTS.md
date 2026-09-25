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
- **DB**: PostgreSQL (`kaptur`, schema `kaptur_schema`), `ddl-auto=update`; manual seeding of `USER_ROLE_MST` required.
- Tests: service + controller tests for auth, events, files.

### Flutter app (`Kaptur/`)
- **GetX modular MVC** (`modules/*/bindings,controllers,views`), routes: `/splash`, `/login`, `/signup`, `/home`.
- **Splash** → auto-login based on session; **Login / Signup** screens with animations; **Google Sign-In v7** (ID token → `/auth/google`).
- **Home dashboard**: stats (events, photos, storage), recent events list, pull-to-refresh, logout.
- **Event CRUD** from the dashboard (create/edit/delete dialogs) wired to backend, with offline fallback mutations.
- **Session layer**: JWT + refresh token in secure storage; `ApiClient` injects Bearer token and auto-refreshes on 401 (deduped) then retries.
- **Theming**: Material 3 light/dark (violet/teal), persisted, follows system.
- Base URL: `http://10.0.2.2:8080` (Android emulator → host) in `lib/data/services/api_constants.dart`.

## 3. What is coming (roadmap / gaps)

### Flutter app
- **Photo gallery & viewer** — the core of the product: event detail screen, photo grid, full-screen viewer, download. Event tiles currently don't navigate anywhere.
- **Photo upload** from the app (TUS resumable upload flow against TUSd, using `/photos/init`).
- **Camera** capture (icons exist but are decorative).
- **Sharing** event links/photos.
- **Subscriptions / payments** (no backend support yet either).
- Fixes: move base URL out of code, release `INTERNET` permission + network security config, form validation, real test suite, remove unused `dio`, stale `AGENTS.md` inside the app repo.

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
