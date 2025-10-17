<!-- 754eb3ed-8794-4ea2-8797-d1384d760fc6 29c23424-0614-4477-b3f1-5f2eb8ae0cf2 -->
# Full Testing Plan (Unit + Provider + Widget + Integration)

## Scope

- Implement tests across four layers with mocked HTTP/services:
- Unit: models, utils, error mapping, caching, repository endpoints
- Provider: state transitions, error/empty/loading, region binding
- Widget: key screens render and react properly given stubbed repos
- Integration: app boot + navigation + favorites/watchlist + search

## Test Infrastructure

- Add test dependencies: `mocktail`, `integration_test`, `flutter_test` (built-in), `http/testing` (optional), `fake_async`.
- Create `test_support/` with:
- `fake_http_client.dart` (route-by-route responses)
- `fixtures/` JSON samples for TMDB endpoints (minimal, curated)
- `fake_tmdb_repository.dart` (implements only used methods; delegates to fixtures)
- `test_app.dart` with `MultiProvider` mirroring `main.dart` but accepts injected `TmdbRepository`, `StaticCatalogService`, and mock `SharedPreferences`.
- Use `SharedPreferences.setMockInitialValues({})` for tests.

## Minimal DI Hook (code edits required)

- Update `AllMoviesApp` to accept optional dependencies and use them if provided; otherwise construct defaults.
- Optional: `TmdbRepository? tmdbRepository`, `StaticCatalogService? catalogService`.
- Keep runtime behavior identical when not provided.

## Unit Tests (targeted files)

- `lib/core/error/error_mapper.dart`: maps HTTP/TMDB errors to domain exceptions.
- `lib/data/services/cache_service.dart`: TTL logic, eviction, periodic cleanup scheduling (no timers in tests; inject clock or expose ttl computation).
- `lib/data/services/local_storage_service.dart`: read/write favorites/watchlist keys; ensure type safety.
- `lib/data/tmdb_repository.dart`: cover representative endpoints:
- trending (titles/movies)
- movies: detail, images, search, discover
- tv: detail, images
- configuration (if used)
- caching path: same request → cached; `forceRefresh` bypasses cache; non-200 → exception
- `lib/data/services/static_catalog_service.dart`: `isFirstRun`, `needsRefresh`, `preloadAll` triggers by locale set.

## Provider Tests (ChangeNotifier)

- `FavoritesProvider`, `WatchlistProvider`: add/remove, persistence, duplicate guard.
- `WatchRegionProvider`: initial region from prefs, change region notifies dependents.
- `MoviesProvider`: initial state, bind region, fetch popular/trending, pagination, error.
- `TrendingTitlesProvider`, `PeopleProvider`, `CompaniesProvider`, `GenresProvider`, `SearchProvider`: happy path + error.

## Widget Tests (key screens)

- `MoviesScreen`: shows list from stub repo; tapping item pushes `MovieDetailScreen`.
- `SearchScreen`: entering query populates results; empty state message.
- `SettingsScreen`: toggling theme/locale updates `MaterialApp`.
- `PeopleScreen` (basic render) and one detail screen smoke: `MovieDetailScreen` structural widgets present given fixture.

## Integration Tests (end-to-end with mocks)

- Entry: `integration_test/app_flow_test.dart` using `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`.
- Flows:
1) Boot + Splash: if `StaticCatalogService.isFirstRun=false`, app navigates to `MoviesScreen`.
2) Favorites/watchlist: open detail → toggle favorites/watchlist → persisted across rebuild.
3) Search: open Search → type query → list renders → open result.
4) Settings: switch theme + locale → verify changes.
- Provide fake repo/service via `AllMoviesApp` optional params.

## Mocking Strategy

- Prefer `mocktail` for behavior verification and throw paths.
- For repository unit tests, use `http.MockClient` to return fixture JSON; assert correct URIs and query params.
- For provider tests, inject a `FakeTmdbRepository` that returns deterministic model instances.
- For widgets/integration, inject same fake and use `SharedPreferences` mock values.

## Directory Layout

- `test/`
- `models/` (existing)
- `providers/` (expand)
- `utils/` (existing + add cache/local_storage/error)
- `widgets/`
- `repository/`
- `test_support/` + `fixtures/`
- `integration_test/`

## Execution

- Run unit/widget tests: `flutter test`
- Run integration tests (per platform, locally): `flutter test integration_test` (uses Flutter integration runner)

## Notes on Coverage & Stability

- Aim ≥75% line coverage on `lib/data/tmdb_repository.dart` and 80% across providers.
- Avoid network/file I/O; all responses via fixtures.
- Use `pumpAndSettle` with timeouts; prefer explicit finders.

### To-dos

- [x] Add mocktail and integration_test deps; create test_support and fixtures structure
- [x] Add optional DI params to AllMoviesApp for repo and catalog service
- [x] Write unit tests for CacheService and LocalStorageService
- [x] Write TmdbRepository tests with MockClient for key endpoints and caching
- [x] Test StaticCatalogService isFirstRun, needsRefresh, preloadAll
- [x] Test FavoritesProvider, WatchlistProvider, WatchRegionProvider behaviors
- [x] Test MoviesProvider, TrendingTitlesProvider, PeopleProvider, GenresProvider, SearchProvider
- [x] Widget tests for MoviesScreen, SearchScreen, SettingsScreen, PeopleScreen, MovieDetailScreen smoke
- [x] Integration tests: boot flow, favorites/watchlist, search, settings toggles
- [x] Add commands to run unit/widget and integration tests locally and document

