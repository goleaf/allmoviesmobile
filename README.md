# AllMovies Mobile (Flutter)

AllMovies Mobile is a Flutter demo app that showcases a modern Material 3 experience for browsing curated movie content.
It includes local authentication, persistent sessions, and dedicated sections for movies, series, people, and production companies.

## ✨ Features

- **Authentication** – Email/password login and registration backed by local storage, with password reset support.
- **Home hub** – Personalized greeting with a searchable grid of featured movies.
- **Navigation drawer** – Profile summary plus quick access to Movies, Series, People, and Companies sections.
- **Section screens** – Each catalog view includes search, filtering, and cards styled for its content type.
- **Material 3 styling** – Dark theme, pill-shaped search bars, and adaptive cards.

## 📱 Screens

| Screen | Description |
| --- | --- |
| Home | Welcome message, featured movies grid, and global navigation actions. |
| Movies | Curated list of cinematic releases with genre and year tags. |
| Series | Highlighted episodic content with season details. |
| People | Talent directory covering actors, directors, and crew. |
| Companies | Production company showcase with headquarters info. |

## 🚀 Getting Started

1. **Install dependencies**
   ```bash
   flutter pub get
   ```
2. **Run the app**
   ```bash
   flutter run
   ```
3. **Platforms** – The project targets Android, iOS, web, and desktop (macOS/Windows/Linux) via Flutter's multiplatform support.

## 🧱 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_routes.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   └── services/
│       └── local_storage_service.dart
├── providers/
│   └── auth_provider.dart
└── presentation/
    ├── screens/
    │   ├── auth/
    │   ├── companies/
    │   ├── home/
    │   ├── movies/
    │   ├── people/
    │   └── series/
    └── widgets/
```

## 🛠 Tooling

- Flutter 3.x
- Provider for state management
- Shared Preferences for local persistence

## 📄 License

This project inherits the licensing terms of the upstream AllMovies repository. See `LICENSE` if present, or contact the maintainers for details.
