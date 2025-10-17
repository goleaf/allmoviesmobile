# AllMovies Flutter client

The Flutter edition of AllMovies brings a lightweight discovery experience to mobile. The
home screen signs the user in locally and then pulls the latest trending movies and TV
shows directly from [TMDB](https://www.themoviedb.org/), rendering them in a responsive
grid that supports search, pull-to-refresh, and inline error handling. If the TMDB API key
is missing or invalid, the grid surfaces an inline error explaining that the key is not
configured and offers a retry button.

## Prerequisites

- Flutter 3.19 or newer
- A TMDB API key – the app expects it to be provided via a `TMDB_API_KEY` dart-define.

## Running the app

Launch the application with your TMDB key using `--dart-define`:

```bash
flutter run --dart-define=TMDB_API_KEY=YOUR_KEY_HERE
```

For release or profile builds, include the same dart-define when invoking
`flutter build`.

## Features

- Local email/password authentication persisted with `SharedPreferences`.
- Dynamic discovery grid backed by TMDB's trending feed.
- Search-as-you-type filtering against the fetched titles.
- Loading, empty, and error states with retry support.
- Pull-to-refresh to request a fresh batch of trending titles.

## Troubleshooting

- **API key missing:** Without the dart-define, the home grid shows "TMDB API key is not configured." along with a retry button.
  Re-run with `--dart-define=TMDB_API_KEY=<value>` to resolve it.
- **Network failures:** Check your connectivity; the grid falls back to an error state with a retry button.
- **No results shown:** The trending feed can occasionally return mixed media without titles. Use the retry action to request a fresh list.
