# AllMovies Flutter App

AllMovies is a Flutter application that showcases a rich authentication experience and a customizable home dashboard for browsing movie content. The app is built with `provider` for state management and `SharedPreferences` for local persistence, bootstrapped directly in the Flutter entry point so the authentication state is immediately available across the widget tree.

## Implemented flows

The project currently focuses on two end-to-end experiences:

- **Authentication** – login, registration, password reset, and persistent sessions handled locally.
- **Home experience** – a Material 3-styled dashboard with navigation, search, and placeholder movie content ready for future data integrations.

Refer to [`FEATURES.md`](FEATURES.md) for a detailed breakdown of every screen, widget, and validation rule that powers these flows.

## Architecture overview

- **Entry point**: `lib/main.dart` wires together `SharedPreferences`, the `LocalStorageService`, and an `AuthProvider` so that authentication state is resolved before the UI renders.
- **State management**: `provider` exposes the authentication state and orchestrates navigation between the login and home screens.
- **Storage**: `LocalStorageService` offers a thin abstraction over `SharedPreferences` for persisting registered users, current session information, and password updates in JSON format.
- **Presentation**: screens and reusable widgets live under `lib/presentation`, following a feature-first directory structure.

## Local storage behaviour

All authentication data lives entirely on device using `SharedPreferences`:

- Registered users are serialized to JSON and stored under the `allmovies_users` key.
- The currently authenticated user is saved separately with the `allmovies_current_user` key to support automatic sign-in.
- Password resets and profile updates mutate the stored JSON payloads atomically to keep the session in sync.

See `lib/data/services/local_storage_service.dart` for the exact serialization and validation logic.

## Getting started

1. **Install Flutter** (3.16 or newer is recommended) and ensure the Flutter SDK is on your `PATH`.
2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the application** on any supported device or emulator:
   ```bash
   flutter run
   ```
   Use `flutter devices` to list the available runtimes (Chrome, iOS Simulator, Android Emulator, macOS, etc.).
4. **Run tests** (optional):
   ```bash
   flutter test
   ```

## Notes on legacy instructions

Earlier versions of this repository documented a native Android (Kotlin) client with TMDB integration. Those Gradle- and TMDB-specific steps are obsolete for the Flutter codebase and have been removed. No TMDB API key is required for the current local-only experience.

## Additional resources

- [`FEATURES.md`](FEATURES.md) – comprehensive feature descriptions and UI inventory.
- [`macos_cursor_runner.sh`](macos_cursor_runner.sh) – optional helper script for launching the Flutter app from macOS terminals.

---

This project follows the licensing terms defined by the upstream AllMovies repository.
