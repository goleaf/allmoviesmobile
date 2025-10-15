package dev.tutushkin.allmovies.domain.settings.models

data class AppSettings(
    val defaultPage: Int,
    val resultsPerPage: Int,
    val castLimit: Int,
    val enforceHttpsForTmdb: Boolean,
    val enforceHttpsForImdb: Boolean,
    val imdbLanguageOverride: String,
    val imdbIpOverride: String,
    val youtubeApiKey: String
)

