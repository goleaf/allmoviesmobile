# AllMovies Flutter App - Feature Documentation

## Overview
AllMovies is a modern Flutter application with Material Design 3, featuring comprehensive authentication and a beautiful movie browsing interface.

## ✨ Features Implemented

### 🎨 **Google Material Design 3**
- Custom dark theme optimized for movie app
- Google Fonts (Poppins) throughout the app
- Modern color scheme with primary indigo theme
- Smooth animations and transitions
- Responsive UI components

### 🔐 **Complete Authentication System**

#### Login Screen
- Email and password validation
- Show/hide password toggle
- Persistent login (stored locally)
- Error handling with user-friendly messages
- Link to register and forgot password

#### Register Screen  
- Full name, email, password fields
- Confirm password validation
- Real-time form validation
- Password strength requirements (min 6 characters)
- Email format validation
- Duplicate email detection
- Auto-login after successful registration

#### Forgot Password Screen
- Email validation
- Generates secure random password
- Displays new password in copyable card
- Copy to clipboard functionality
- Password saved locally for future login

### 💾 **Local Data Storage**
- All user data stored locally using SharedPreferences
- No external server/API required
- Persistent user sessions
- Multiple user support
- Secure password handling

### 🏠 **Home Screen with Navigation**

#### Top App Bar
- **Left**: Movie icon logo + "AllMovies" branding
- **Center**: Search bar with real-time input
- **Right**: Hamburger menu icon

#### Movie Grid
- Responsive 2-column grid layout fed by TMDB trending and popular endpoints
- Requires a TMDB API key supplied via `--dart-define=TMDB_API_KEY=<your_key>`
- Filter chips for **All**, **Trending**, and **Popular** collections
- Sorting controls for popularity, rating, release date, and title
- Real-time search that narrows results within the chosen collection

#### Side Drawer
- User profile header with avatar
- Navigation menu items:
  - Home
  - Movies
  - Series
  - People
  - Companies
  - Favorites (placeholder)
  - Settings (placeholder)
  - About
- Logout button at bottom
- Only visible when logged in

### ✅ **Form Validation**
- Email validation (proper format check)
- Password requirements (minimum 6 characters)
- Confirm password matching
- Required field validation
- Real-time error messages
- Visual feedback for errors

### 📱 **UI Components**

#### Custom Widgets
- `CustomTextField`: Reusable form field with icons
- `LoadingOverlay`: Full-screen loading indicator
- `AppDrawer`: Navigation drawer with user profile

#### Design Features
- Card-based layouts
- Rounded corners throughout
- Consistent spacing and padding
- Icon integration
- Smooth state transitions

### 🎬 **Core Content Discovery**

#### Movies
- Browse curated movie collections powered by TMDB
- Popular movies with paginated infinite scroll
- Top rated movies for critically acclaimed picks
- Now playing titles currently in theaters
- Upcoming releases to plan future watchlists
- Latest additions for newly released content
- Browse movies by decade from the 1900s through the 2020s
- Filter by any of the 28 TMDB genres
- Discover films by country or region of origin
- Explore movies by original language
- View titles by certification (G, PG, PG-13, R, etc.)
- Surface box office hits ranked by revenue

### 📸 **Media & Images**
- Posters (vertical), backdrops (horizontal), profile stills, production logos, and episodic still images rendered in dedicated carousels.
- Users can switch between TMDB image sizes (`w92`, `w154`, `w185`, `w342`, `w500`, `w780`, `original`) per asset type to balance fidelity and bandwidth.
- Images stream in lazily with shimmer placeholders and fade-in progressive loading so long lists stay responsive.
- Placeholder art and explicit error states ensure broken or missing assets never break layout integrity.
- All artwork flows through `CachedNetworkImage`, giving automatic disk caching, retry logic, and offline reuse for previously viewed assets.

### 🎥 **Video Player**
- Embedded YouTube trailers sit inline on detail pages with branded metadata and preview thumbnails.
- Supports trailer, teaser, clip, featurette, and behind-the-scenes categories with quick filters so users can jump to the content they care about.
- Custom player chrome surfaces play/pause, seek, quality selection, caption toggles, and an auto-play switch that persists between sessions.
- Full-screen mode uses system overlays for an immersive viewing experience while preserving the ability to dismiss and resume from the exact timestamp.
- Thumbnails and metadata hydrate instantly while the player streams progressively, avoiding layout shifts and keeping navigation snappy.

## 🏗️ Project Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_routes.dart     # Centralized route names
│   │   └── app_strings.dart    # All UI strings
│   ├── theme/
│   │   └── app_theme.dart      # Material Design 3 theme
│   └── utils/
│       └── validators.dart     # Form validation logic
├── data/
│   ├── models/
│   │   └── user_model.dart     # User data model
│   └── services/
│       └── local_storage_service.dart  # SharedPreferences wrapper
├── providers/
│   └── auth_provider.dart      # Authentication state management
└── presentation/
    ├── screens/
    │   ├── auth/
    │   ├── companies/
    │   ├── home/
    │   ├── movies/
    │   ├── people/
    │   └── series/
    └── widgets/
        ├── app_drawer.dart
        ├── custom_text_field.dart
        ├── loading_overlay.dart
        ├── media_section_screen.dart
        └── section_navigation_actions.dart
```

## 📦 Dependencies

### Production
- `provider`: State management
- `shared_preferences`: Local storage
- `google_fonts`: Typography
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching
- `http`: HTTP client
- `json_annotation`: JSON serialization
- `email_validator`: Email validation
- `uuid`: Unique ID generation

### Development
- `build_runner`: Code generation
- `json_serializable`: JSON code gen
- `flutter_lints`: Linting rules

## 🚀 How to Run

### Using the Runner Script
```bash
# Run on Chrome (recommended for testing)
./macos_cursor_runner.sh --device-id chrome

# Run on macOS desktop (requires Xcode)
./macos_cursor_runner.sh --device-id macos

# Run on iOS Simulator (requires Xcode)
./macos_cursor_runner.sh --platform ios

# Run on Android emulator
./macos_cursor_runner.sh --platform android --avd-name <your_avd>
```

### Manual Run
```bash
flutter pub get
flutter run -d chrome  # or any device
```

## 🔑 Test the App

### Create a Test Account
1. Launch the app → Login screen appears
2. Click "Register" button
3. Fill in:
   - Full Name: John Doe
   - Email: john@example.com
   - Password: test123
   - Confirm Password: test123
4. Click "Register" → Auto-logged in to Home

### Test Login
1. Logout from drawer
2. Login with: john@example.com / test123
3. Successfully logged in

### Test Forgot Password
1. Logout
2. Click "Forgot Password?"
3. Enter: john@example.com
4. New password generated and displayed
5. Copy password
6. Return to login with new password

## 🎯 Key Features

### ✅ All Local - No Backend Required
- 100% offline functionality
- Data persists between app restarts
- Multiple user accounts supported

### ✅ Production-Ready UI
- Material Design 3 guidelines
- Professional animations
- Responsive layouts
- Accessibility support

### ✅ Secure & Validated
- All inputs validated
- Password requirements enforced
- Error handling throughout
- User feedback for all actions

### ✅ Extensible Architecture
- Clean separation of concerns
- Easy to add new features
- Live TMDB integration for trending discovery
- Modular component design

## 🔮 Ready for Extension

The architecture is designed to easily add:
- Additional catalog sources (e.g., OMDB) alongside TMDB
- Favorites system
- Movie details page
- User preferences/settings
- Offline caching
- Push notifications

## 📝 Notes

- All user data is stored locally in SharedPreferences
- Passwords are stored as plain text (for demo purposes)
- In production, use proper encryption and secure storage
- Ready to integrate with any movie API
- Search bar filters the fetched TMDB titles locally
