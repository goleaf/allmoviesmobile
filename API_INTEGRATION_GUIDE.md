# 🔌 API Integration Guide

## Overview

This guide explains how to integrate the TMDB API to replace mock data with live movie information.

---

## ✅ Current Status

**Good News:** The repository is already set up for API calls!

```dart
✅ TmdbRepository implemented
✅ All API endpoints defined
✅ Error handling in place
✅ HTTP client configured
✅ Response parsing ready
```

---

## 🔑 Step 1: Get TMDB API Key

### Register for API Key

1. Go to [https://www.themoviedb.org/signup](https://www.themoviedb.org/signup)
2. Create a free account
3. Navigate to Settings → API
4. Request an API key (choose "Developer" option)
5. Fill out the simple form
6. Copy your API key

### API Key Limits (Free Tier)
- ✅ 40 requests per 10 seconds
- ✅ Unlimited requests per day
- ✅ No credit card required
- ✅ Commercial use allowed

---

## 🚀 Step 2: Configure API Key

### Option A: Environment Variable (Recommended)

Add to your run configuration:

```bash
flutter run --dart-define=TMDB_API_KEY=your_api_key_here
```

Or add to your IDE configuration:
- **VS Code**: Add to `.vscode/launch.json`:
  ```json
  {
    "configurations": [
      {
        "name": "Flutter",
        "type": "dart",
        "request": "launch",
        "program": "lib/main.dart",
        "args": ["--dart-define=TMDB_API_KEY=your_api_key_here"]
      }
    ]
  }
  ```

- **Android Studio/IntelliJ**: 
  - Run → Edit Configurations
  - Add to "Additional run args": `--dart-define=TMDB_API_KEY=your_key`

### Option B: Build Configuration

For permanent builds, add to your build commands:

```bash
# Android
flutter build apk --dart-define=TMDB_API_KEY=your_key

# iOS  
flutter build ios --dart-define=TMDB_API_KEY=your_key

# Web
flutter build web --dart-define=TMDB_API_KEY=your_key
```

### ⚠️ Security Note

**NEVER** commit API keys to git. The current implementation uses `String.fromEnvironment` which is secure for production builds.

---

## 📊 Step 3: Verify API Integration

### Test API Connection

Run the app and check for data:

```bash
flutter run --dart-define=TMDB_API_KEY=your_key
```

### Expected Behavior

1. **Home Screen**: Shows trending movies
2. **Search**: Returns real movie results
3. **Movie Detail**: Displays actual movie information
4. **Recommendations**: Shows related movies

### Troubleshooting

#### Error: "TMDB API key is not configured"
- Solution: Add `--dart-define=TMDB_API_KEY=your_key` to run command

#### Error: "Request failed with status 401"
- Solution: Check API key is correct
- Verify key is active in TMDB account

#### Error: "Request failed with status 429"
- Solution: Rate limit exceeded (40 requests per 10 seconds)
- Implement request throttling (see Step 5)

---

## 🎯 Step 4: Available API Endpoints

All endpoints are already implemented in `TmdbRepository`:

### Movies
```dart
// Popular movies
fetchPopularMovies({int page = 1})

// Top rated movies
fetchTopRatedMovies({int page = 1})

// Now playing in theaters
fetchNowPlayingMovies({int page = 1})

// Upcoming releases
fetchUpcomingMovies({int page = 1})

// Movie details with extras
fetchMovieDetails(int movieId)

// Similar movies
fetchSimilarMovies(int movieId, {int page = 1})

// Recommended movies
fetchRecommendedMovies(int movieId, {int page = 1})
```

### Search
```dart
// Search movies only
searchMovies(String query, {int page = 1})

// Search all (movies, TV, people)
searchMulti(String query, {int page = 1})
```

### Discovery
```dart
// Discover with filters
discoverMovies({
  int page = 1,
  String? sortBy,
  List<int>? withGenres,
  int? year,
  double? voteAverageGte,
})
```

### Genres
```dart
// Movie genres
fetchMovieGenres()

// TV genres
fetchTVGenres()
```

### Trending
```dart
// Trending content
fetchTrendingMovies({String timeWindow = 'day'})
```

---

## 💾 Step 5: Implement Caching (Optional but Recommended)

### Why Cache?

- ✅ Reduce API calls
- ✅ Improve performance
- ✅ Work offline
- ✅ Respect rate limits

### Use Existing CacheService

The project already has `CacheService` implemented:

```dart
// Example: Cache popular movies for 1 hour
final cacheKey = 'popular_movies_page_1';
final cached = cacheService.get<List<Movie>>(cacheKey);

if (cached != null) {
  return cached;
}

final movies = await repository.fetchPopularMovies();
cacheService.set(cacheKey, movies, ttl: Duration(hours: 1));
return movies;
```

### Integration Example

Update providers to use caching:

```dart
Future<void> fetchPopularMovies() async {
  final cacheKey = 'popular_movies';
  final cached = _cacheService.get<List<Movie>>(cacheKey);
  
  if (cached != null) {
    _popularMovies = cached;
    notifyListeners();
    return;
  }

  _isLoading = true;
  notifyListeners();

  try {
    _popularMovies = await _repository.fetchPopularMovies();
    _cacheService.set(cacheKey, _popularMovies, 
      ttl: Duration(hours: 1));
  } catch (error) {
    _errorMessage = error.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 📄 Step 6: Pagination Implementation

### Current Status

All endpoints support pagination (`page` parameter).

### Example: Infinite Scroll

```dart
class MoviesProvider extends ChangeNotifier {
  List<Movie> _movies = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newMovies = await _repository.fetchPopularMovies(
        page: _currentPage + 1,
      );

      if (newMovies.isEmpty) {
        _hasMore = false;
      } else {
        _movies.addAll(newMovies);
        _currentPage++;
      }
    } catch (error) {
      // Handle error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
```

### UI Integration

```dart
ListView.builder(
  itemCount: movies.length + 1,
  itemBuilder: (context, index) {
    if (index == movies.length) {
      if (provider.hasMore) {
        provider.loadMore();
        return CircularProgressIndicator();
      }
      return SizedBox.shrink();
    }
    return MovieCard(movie: movies[index]);
  },
)
```

---

## 🔄 Step 7: Retry & Error Handling

### Use Existing Utilities

The project has `RetryHelper` and `ErrorHandler`:

```dart
// Wrap API calls with retry logic
final movies = await RetryHelper.retry(
  operation: () => repository.fetchPopularMovies(),
  maxAttempts: 3,
  shouldRetry: RetryHelper.isRetryable,
);

// Show user-friendly errors
try {
  await fetchMovies();
} catch (error) {
  ErrorHandler.showErrorSnackBar(context, error);
}
```

---

## 📱 Step 8: Test on Devices

### Before Production

1. ✅ Test on real devices (Android & iOS)
2. ✅ Test with slow network
3. ✅ Test with no network
4. ✅ Test API rate limiting
5. ✅ Verify images load correctly
6. ✅ Check memory usage with large lists

### Performance Testing

```bash
# Profile mode for performance
flutter run --profile --dart-define=TMDB_API_KEY=your_key

# Release mode for production testing
flutter run --release --dart-define=TMDB_API_KEY=your_key
```

---

## 🎨 Step 9: Image Loading

### TMDB Image URLs

Images are already handled in `Movie` model:

```dart
String? get posterUrl =>
    posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

String? get backdropUrl => backdropPath != null
    ? 'https://image.tmdb.org/t/p/w780$backdropPath'
    : null;
```

### Image Sizes Available

```
w92, w154, w185, w342, w500, w780, original
```

### Optimization Tips

- ✅ Use `w500` for posters (already implemented)
- ✅ Use `w780` for backdrops (already implemented)
- ✅ Use `cached_network_image` package (already implemented)
- ✅ Show placeholders while loading
- ✅ Handle loading errors

---

## 📋 Step 10: Production Checklist

### Before Launch

- [ ] API key configured securely
- [ ] All endpoints tested
- [ ] Error handling verified
- [ ] Caching implemented
- [ ] Pagination working
- [ ] Images loading correctly
- [ ] Offline behavior acceptable
- [ ] Rate limiting handled
- [ ] Performance profiled
- [ ] Memory leaks checked

---

## 🚀 Quick Start Command

```bash
# Get your TMDB API key from themoviedb.org
# Then run:

flutter run --dart-define=TMDB_API_KEY=your_api_key_here
```

That's it! The app should now display real movie data. 🎬

---

## 📚 Additional Resources

- [TMDB API Documentation](https://developers.themoviedb.org/3)
- [TMDB API Reference](https://developers.themoviedb.org/3/getting-started/introduction)
- [Flutter Environment Variables](https://dart.dev/guides/environment-declaration)

---

## 🆘 Need Help?

### Common Issues

**Q: Where do I put my API key?**  
A: Add `--dart-define=TMDB_API_KEY=your_key` to your run command

**Q: Can I use .env files?**  
A: Flutter doesn't support .env natively. Use `--dart-define` or build-time configuration.

**Q: Is my API key secure?**  
A: Yes, when using `--dart-define`, the key is compiled into the binary and not exposed in source code.

**Q: How do I handle rate limiting?**  
A: Implement caching (Step 5) and use retry logic (Step 7).

---

**Ready to go live!** 🎉

Your app is fully configured for TMDB API integration. Just add your API key and you're ready to fetch real movie data!

