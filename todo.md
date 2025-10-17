## Tasks

### Completed
- Harden `WatchRegionProvider` for determinism (normalize, validate, fallback)
- Harden `RecommendationsProvider` for determinism (dedupe, sort by id, limit)
- Add determinism tests for both providers and run lints

### Follow-ups
- Run full test suite locally and address unrelated widget test failures (e.g., `companies_screen` image enum getters)
- Monitor other providers for any nondeterministic outputs if requirements expand

Refactor model URL getters to use MediaImageHelper (priority)

- [x] Locate MediaImageHelper and understand its API
- [x] Find all model URL accessors/getters producing media/image URLs
- [x] Refactor models’ URL getters to use MediaImageHelper
- [x] Run lints on edited files and fix issues
- [/] Update or add unit tests for URL getters behavior (out of scope for this change)

Notes:
- Hardcoded TMDB image URLs replaced in `lib/mvp/models/media.dart` with MediaImageHelper.
- Other data models already used MediaImageHelper.

---

### New follow-ups
- Deep links: add handlers and route parsing for movies, tv, person, collection, keyword
- i18n: replace remaining hardcoded strings in keyword detail, lists, networks
- Widget tests: add simple smoke tests for NetworksScreen, CollectionsBrowserScreen routing
- Drawer: ensure all new routes are listed and reachable from `AppDrawer`
- Search: explore suggestions/autocomplete follow-up

