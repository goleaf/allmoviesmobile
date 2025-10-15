package dev.tutushkin.allmovies.domain.settings.models

object AppSettingsDefaults {
    const val DEFAULT_PAGE = 1
    const val RESULTS_PER_PAGE = 12
    const val CAST_LIMIT = 12
    const val ENFORCE_HTTPS_TMDB = true
    const val ENFORCE_HTTPS_IMDB = true
    const val IMDB_LANGUAGE = "en-US"
    const val IMDB_IP_OVERRIDE = ""
    const val YOUTUBE_API_KEY = ""

    fun default(): AppSettings = AppSettings(
        defaultPage = DEFAULT_PAGE,
        resultsPerPage = RESULTS_PER_PAGE,
        castLimit = CAST_LIMIT,
        enforceHttpsForTmdb = ENFORCE_HTTPS_TMDB,
        enforceHttpsForImdb = ENFORCE_HTTPS_IMDB,
        imdbLanguageOverride = IMDB_LANGUAGE,
        imdbIpOverride = IMDB_IP_OVERRIDE,
        youtubeApiKey = YOUTUBE_API_KEY
    )
}

