Refactor model URL getters to use MediaImageHelper (priority)

- [x] Locate MediaImageHelper and understand its API
- [x] Find all model URL accessors/getters producing media/image URLs
- [x] Refactor models’ URL getters to use MediaImageHelper
- [x] Run lints on edited files and fix issues
- [/] Update or add unit tests for URL getters behavior (out of scope for this change)

Notes:
- Hardcoded TMDB image URLs replaced in `lib/mvp/models/media.dart` with MediaImageHelper.
- Other data models already used MediaImageHelper.

