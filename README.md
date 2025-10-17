# AllMovies Mobile

AllMovies Mobile is a Flutter demo application that showcases a lightweight movie browsing experience with local-only authentication. The project focuses on clear UI structure, state management with `provider`, and persistence via `SharedPreferences`.

## Features

- Email/password registration and login stored locally on the device.
- Searchable mock catalog of ten sample movies with genre and year metadata.
- Favorites and watchlist collections that persist across app launches.
- Drawer navigation to the Home, Favorites, Watchlist, and Settings screens.
- Settings screen outlining planned appearance and localization controls.

## Getting started

1. Install the latest stable [Flutter](https://docs.flutter.dev/get-started/install) SDK and ensure `flutter doctor` reports no unresolved issues.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an available emulator or device:
   ```bash
   flutter run
   ```

The application uses `SharedPreferences` for local storage. No remote services or API keys are required.

## Project structure

```
lib/
├── core/              # Theme and string constants
├── data/              # Models, repositories, and local storage helpers
├── presentation/      # UI screens and widgets
└── providers/         # State management classes
```

## Settings screen

The Settings screen currently highlights upcoming customization features (theme and language controls). These items are labelled as planned so users understand they are not yet interactive.

## Testing

Widget and unit tests can be executed with:

```bash
flutter test
```

## License

This project follows the licensing terms defined by the upstream AllMovies repository.
