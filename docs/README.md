# AllMovies Mobile (Flutter)

AllMovies Mobile is a Flutter application that showcases a local-first movie browsing experience with Material Design 3 styling. The app bootstraps in [`lib/main.dart`](lib/main.dart), where SharedPreferences-backed storage is initialised and the authentication provider decides whether to display the login flow or the home screen. For a breakdown of every implemented screen and widget, see [`FEATURES.md`](FEATURES.md).

## Project overview
- Built with Flutter and Dart, targeting mobile, web, and desktop platforms supported by Flutter.
- Uses the `provider` package for app-wide state management and `shared_preferences` for local persistence.
- Integrates with [TMDB](https://www.themoviedb.org/) to populate the discovery grid; provide your API key via the `TMDB_API_KEY` dart-define when running builds.

## Authentication flow
Authentication is entirely local and stored in SharedPreferences through `LocalStorageService`:

1. **Register** – Creates a user entry in SharedPreferences and immediately signs in.
2. **Login** – Validates credentials against the locally stored users and, on success, flips the `AuthProvider` state to display the home screen.
3. **Forgot password** – Generates and stores a replacement password for the supplied email, surfacing it in-app for the user to copy.
4. **Logout** – Clears the active session flag from SharedPreferences and returns the user to the login screen.

Because there is no backend, credentials never leave the device. Multiple accounts can be created for testing, and state persists across restarts thanks to SharedPreferences.

## Home screen expectations
After authentication, users land on a TMDB-backed home screen that fetches the latest trending movies and TV shows:

- Two-column grid of card-based movie tiles populated by TMDB's trending feed.
- Search field that filters the fetched titles locally as you type.
- Drawer options (Favourites, Settings) are present as stubs for future work.

If the TMDB API key is missing or invalid, the grid falls back to an inline error state explaining that the key is not configured ("TMDB API key is not configured.") and offers a retry button. This is the expected behaviour until a valid `TMDB_API_KEY` dart-define is supplied.

## Running the app
The repository includes a `macos_cursor_runner.sh` helper for launching Flutter builds from Cursor on macOS, but you can also run everything manually with the Flutter CLI.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) set up for your platform (Flutter 3.19 or newer recommended).
- Device or emulator supported by Flutter (Chrome, macOS, iOS, Android, etc.).
- TMDB API key available to pass via the `TMDB_API_KEY` dart-define.

### Using the runner script (macOS only)
```bash
./macos_cursor_runner.sh --device-id chrome   # or macos, ios, android
```

> **Note:** Ensure the script's `flutter run` invocation passes `--dart-define=TMDB_API_KEY=YOUR_KEY_HERE` before using it, or fall back to the manual commands below.

### Manual commands
```bash
flutter pub get
flutter run -d <device_id> --dart-define=TMDB_API_KEY=YOUR_KEY_HERE
```

For release or profile builds, include the same dart-define when invoking `flutter build`.

## Maintaining Isar schemas
When regenerating the local database bindings, use the helper script to keep schema and index IDs within the JavaScript safe integer range required by Flutter web builds:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run tool/ensure_web_safe_isar_ids.dart --fix
```

The second command scans every generated file under `lib/data/local/isar/`, clamps any out-of-range IDs, and fails the build if run without `--fix` while violations remain.

## Additional resources
- [`FEATURES.md`](FEATURES.md) – Detailed feature list, architecture overview, and usage tips.
- [`QA_CHECKLIST.md`](QA_CHECKLIST.md) – Quality checklist maintained for the project.

## License
This project follows the licensing terms defined by the upstream AllMovies repository.
