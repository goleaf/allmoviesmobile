# AllMovies Mobile

AllMovies Mobile is a Flutter application that showcases a local-first movie browsing experience with Material Design 3 styling. The app bootstraps in [`lib/main.dart`](lib/main.dart), where SharedPreferences-backed storage is initialised and the authentication provider decides whether to display the login flow or the home screen. For a breakdown of every implemented screen and widget, see [`FEATURES.md`](FEATURES.md).

## Project overview
- Built with Flutter and Dart, targeting mobile, web, and desktop platforms supported by Flutter.
- Uses the `provider` package for app-wide state management and `shared_preferences` for local persistence.
- Ships with placeholder movie grid content so it can run without external APIs.

## Authentication flow
Authentication is entirely local and stored in SharedPreferences through `LocalStorageService`:

1. **Register** – Creates a user entry in SharedPreferences and immediately signs in.
2. **Login** – Validates credentials against the locally stored users and, on success, flips the `AuthProvider` state to display the home screen.
3. **Forgot password** – Generates and stores a replacement password for the supplied email, surfacing it in-app for the user to copy.
4. **Logout** – Clears the active session flag from SharedPreferences and returns the user to the login screen.

Because there is no backend, credentials never leave the device. Multiple accounts can be created for testing, and state persists across restarts thanks to SharedPreferences.

## Home screen expectations
After authentication, users land on a placeholder home screen that demonstrates the final layout without calling a movie API:

- Two-column grid of card-based movie tiles populated with sample data.
- Search field and navigation drawer wired into the layout but not yet backed by network requests.
- Drawer options (Favourites, Settings) are present as stubs for future work.

This design provides a visual reference for the planned experience while keeping the project runnable offline.

## Running the app
The repository includes a `macos_cursor_runner.sh` helper for launching Flutter builds from Cursor on macOS, but you can also run everything manually with the Flutter CLI.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) set up for your platform.
- Device or emulator supported by Flutter (Chrome, macOS, iOS, Android, etc.).

### Using the runner script (macOS only)
```bash
./macos_cursor_runner.sh --device-id chrome   # or macos, ios, android
```

### Manual commands
```bash
flutter pub get
flutter run -d <device_id>
```

## Additional resources
- [`FEATURES.md`](FEATURES.md) – Detailed feature list, architecture overview, and usage tips.
- [`QA_CHECKLIST.md`](QA_CHECKLIST.md) – Quality checklist maintained for the project.

## License
This project follows the licensing terms defined by the upstream AllMovies repository.
