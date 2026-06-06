# Kaptur — AI Agent Context

## Project Overview
Kaptur ("Find your moments in a blink") is a Flutter-based photo/event management mobile app — a clone of "FotoOwl". It lets users authenticate (email/password + Google Sign-In), view a dashboard of photo events with stats, and manage their memories. The backend is a separate Spring Boot project at `../Kaptur-backend/`.

## Tech Stack
- **Framework:** Flutter 3.41.7 (managed via FVM — `.fvmrc`)
- **Language:** Dart SDK ^3.9.2
- **State Management & Routing:** GetX (`get: ^4.6.6`)
- **Networking:** `http` package (primary), `dio: ^5.4.3+1` (dependency present but unused)
- **Auth:** `google_sign_in: ^6.2.1` for native Google OAuth
- **Secure Storage:** `flutter_secure_storage: ^9.0.0` (JWT tokens)
- **Local Storage:** `get_storage: ^2.1.1` (user profile data, non-sensitive)
- **Date Formatting:** `intl: ^0.20.2`
- **Linting:** `flutter_lints: ^5.0.0` via `analysis_options.yaml`
- **Design System:** Material 3 with custom violet/teal palette

## Project Structure (lib/)
```
lib/
├── main.dart                                  # Entry point; GetMaterialApp, GetStorage init
├── core/
│   ├── theme/app_theme.dart                   # Centralized light/dark ThemeData (violet + teal)
│   └── utils/snackbar_utils.dart              # AppSnackbar utility (success/error/info)
├── data/
│   ├── models/
│   │   ├── users.dart                         # User model (fromJson/toJson)
│   │   └── event_model.dart                   # Event model (id, name, imageCount, sizeInMb, createdAt)
│   └── services/
│       ├── api_client.dart                    # Centralized HTTP client with JWT header injection
│       ├── api_constants.dart                 # Base URL (http://10.0.2.2:8080) + endpoint paths
│       └── auth_service.dart                  # Auth API calls (login, register, googleLogin)
├── modules/
│   ├── auth/
│   │   ├── bindings/auth_binding.dart         # DI binding for AuthController
│   │   ├── controllers/auth_controller.dart   # Login, register, Google sign-in, logout, session persistence
│   │   └── views/
│   │       ├── login_screen.dart              # Email/password + Google login
│   │       └── signup_screen.dart             # Registration with animated form card
│   ├── home/
│   │   ├── bindings/home_binding.dart         # DI binding for HomeController
│   │   ├── controllers/home_controller.dart   # Event list (currently mock data), computed stats
│   │   └── views/home_screen.dart             # Dashboard: stats cards + event list + FAB
│   └── before_login/                          # Placeholder module (empty files)
│       ├── bindings/before_login_bindings.dart
│       ├── controllers/before_login_controller.dart
│       └── views/before_login_view.dart
├── routes/
│   ├── app_pages.dart                         # GetPage route definitions + bindings
│   └── app_routes.dart                        # Route name constants (part of app_pages.dart)
└── widgets/
    └── theme_toggle_button.dart               # Light/dark mode toggle button
```

## Architecture Pattern
**GetX modular MVC** — each feature module under `modules/` follows a strict 3-folder convention:

| Folder        | Purpose                                                       |
|---------------|---------------------------------------------------------------|
| `bindings/`   | `Get.lazyPut()` DI registration (use `fenix: true` for re-creation) |
| `controllers/`| Extend `GetxController`; hold `.obs` reactive state + business logic |
| `views/`      | Stateless/stateful widgets; use `Obx()` for reactivity, `GetView<T>` for typed access |

- Routes are defined in `routes/app_pages.dart` using `GetPage` with bindings attached.
- Initial route: `/login` (`Routes.login`).
- Navigation: `Get.toNamed()`, `Get.offAllNamed()`, `Get.back()`.

## API Layer
- **Base URL:** `http://10.0.2.2:8080` (Android emulator → host localhost)
- **ApiClient:** Centralized HTTP client that auto-injects JWT from `FlutterSecureStorage` into `Authorization: Bearer` header.
- **AuthService:** Wraps ApiClient for auth endpoints:
  - `POST /auth/login` → returns `{ accessToken, user }`
  - `POST /auth/register` → returns user
  - `POST /auth/google` → returns `{ accessToken, user }`
- Backend is a Spring Boot project at `../fotoowl-backend/`.

## Auth Flow
1. App starts → `AuthController.onInit()` calls `checkLoginStatus()`.
2. Reads JWT from `FlutterSecureStorage` + user data from `GetStorage`.
3. If valid → auto-navigates to `/home`.
4. Login/Register → JWT stored securely, user JSON stored in GetStorage, `isLoggedIn` set to `true`.
5. Logout → clears both storages, signs out Google, navigates to `/login`.

## Theme System
- Two prebuilt `ThemeData` in `AppTheme.light` and `AppTheme.dark`.
- Primary: soft violet (`#6B5FE4` light / `#8B82F0` dark).
- Secondary: calm teal (`#3CBFB4` light / `#57D4C9` dark).
- Background: light lavender-white / deep dark violet-black.
- All widgets should read from `Theme.of(context)` — **never hard-code colors**.
- `ThemeToggleButton` widget toggles via `Get.changeThemeMode()`.
- Theme mode defaults to `ThemeMode.system`.

## Key Dependencies
| Package                 | Purpose                                    |
|-------------------------|--------------------------------------------|
| `get`                   | State management, routing, DI, utilities   |
| `http`                  | HTTP requests to Spring Boot backend       |
| `dio`                   | HTTP client (added but not yet in use)     |
| `google_sign_in`        | Native Google Sign-In                      |
| `flutter_secure_storage`| Encrypted JWT token storage                |
| `get_storage`           | Lightweight key-value storage (user data)  |
| `intl`                  | Date/number formatting                     |
| `rename_app`            | App renaming utility                       |
| `change_app_package_name`| Package name changer (dev dependency)     |

## Common Commands
```bash
flutter run              # Run the app
flutter pub get          # Install dependencies
flutter test             # Run tests
flutter analyze          # Static analysis / lint check
flutter build apk        # Build Android APK
flutter build ios        # Build iOS
flutter build web        # Build for web
fvm flutter run          # Run with FVM-managed Flutter version
```

## Code Style & Conventions
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- `snake_case` for file names, `PascalCase` for class names, `camelCase` for variables/methods.
- Prefer `const` constructors where possible.
- Use `///` triple-slash for doc comments on public APIs.
- Use descriptive variable names; extract complex conditions into boolean variables.
- Use `Obx()` for reactive UI bindings in views.
- Views should be `StatelessWidget` (or `GetView<T>`) when possible; use `StatefulWidget` only when needed (e.g., animation controllers, text field controllers).
- Keep business logic in controllers — views should be UI-only.
- All network calls go through `ApiClient` → service classes.

## Current State / TODO Areas
- `before_login` module exists but is empty (placeholder for onboarding/splash).
- `HomeController` uses **mock data** — not yet connected to backend API.
- `dio` dependency is present but not used (migration from `http` may be planned).
- Home screen "Create Event" FAB has no implementation yet.
- "View All" button on recent events has no navigation.
- No image upload/viewing functionality yet.
- No dedicated event detail screen yet.
