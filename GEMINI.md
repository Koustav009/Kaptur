# Project Overview: fotoowlclone

This is a Flutter-based mobile and web application, currently serving as a clone of "FotoOwl". The project is in its early stages, utilizing the standard Flutter boilerplate.

## Technologies
- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** [Dart](https://dart.dev/)
- **Icons:** Cupertino Icons
- **Linting:** `flutter_lints`

## Architecture
The project follows a standard Flutter directory structure:
- `lib/`: Contains the main source code.
  - `main.dart`: Entry point of the application.
- `test/`: Contains unit and widget tests.
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`: Platform-specific configurations and code.

---

## Building and Running

### Prerequisites
- Flutter SDK (version `^3.9.2` or higher)
- Dart SDK
- Android Studio / Xcode / VS Code with Flutter extension

### Key Commands
- **Run the app:** `flutter run`
- **Install dependencies:** `flutter pub get`
- **Run tests:** `flutter test`
- **Analyze code:** `flutter analyze`
- **Build for Android:** `flutter build apk`
- **Build for iOS:** `flutter build ios`
- **Build for Web:** `flutter build web`

---

## Development Conventions

### Coding Style
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- Use `flutter analyze` to ensure code quality and adherence to linting rules defined in `analysis_options.yaml`.
- Prefer `const` constructors where possible to optimize performance.
- Use `snake_case` for file names and `PascalCase` for class names.

### State Management
- Currently, the project uses basic `setState`. As the project grows, consider implementing a state management solution like `Provider`, `Riverpod`, or `Bloc`.

### Testing
- Place widget tests in the `test/` directory.
- Ensure all new features are accompanied by relevant tests.
- Run `flutter test` before committing changes.

### Documentation
- Use triple-slash (`///`) comments for docstrings on classes and methods.
- Keep the `README.md` updated with major changes.
- Add comments in easy terms to assist with the learning phase, as requested in global context.

# Project Context
This is the frontend for the App.

## Backend Context
Refer to the spring boot backend here and make changes according to it:
@../fotoowl-backend/GEMINI.md
@../fotoowl-backend/README.md
@../fotoowl-backend/