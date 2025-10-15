package dev.tutushkin.allmovies.data.settings.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.toMutablePreferences
import androidx.datastore.preferences.preferencesDataStore
import androidx.datastore.preferences.SharedPreferencesMigration
import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import dev.tutushkin.allmovies.domain.settings.models.AppSettingsDefaults
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private const val SETTINGS_DATA_STORE_NAME = "app_settings"

val Context.settingsDataStore: DataStore<Preferences> by preferencesDataStore(
    name = SETTINGS_DATA_STORE_NAME,
    produceMigrations = { context ->
        listOf(
            SharedPreferencesMigration(context, SETTINGS_DATA_STORE_NAME) { _, current ->
                if (current.isEmpty()) {
                    current.toMutablePreferences().apply {
                        this[DEFAULT_PAGE_KEY] = AppSettingsDefaults.DEFAULT_PAGE
                        this[RESULTS_PER_PAGE_KEY] = AppSettingsDefaults.RESULTS_PER_PAGE
                        this[CAST_LIMIT_KEY] = AppSettingsDefaults.CAST_LIMIT
                        this[ENFORCE_HTTPS_TMDB_KEY] = AppSettingsDefaults.ENFORCE_HTTPS_TMDB
                        this[ENFORCE_HTTPS_IMDB_KEY] = AppSettingsDefaults.ENFORCE_HTTPS_IMDB
                        this[IMDB_LANGUAGE_KEY] = AppSettingsDefaults.IMDB_LANGUAGE
                        this[IMDB_IP_OVERRIDE_KEY] = AppSettingsDefaults.IMDB_IP_OVERRIDE
                        this[YOUTUBE_API_KEY] = AppSettingsDefaults.YOUTUBE_API_KEY
                    }
                } else {
                    current
                }
            }
        )
    }
)

private val DEFAULT_PAGE_KEY = intPreferencesKey("default_page")
private val RESULTS_PER_PAGE_KEY = intPreferencesKey("results_per_page")
private val CAST_LIMIT_KEY = intPreferencesKey("cast_limit")
private val ENFORCE_HTTPS_TMDB_KEY = booleanPreferencesKey("enforce_https_tmdb")
private val ENFORCE_HTTPS_IMDB_KEY = booleanPreferencesKey("enforce_https_imdb")
private val IMDB_LANGUAGE_KEY = stringPreferencesKey("imdb_language")
private val IMDB_IP_OVERRIDE_KEY = stringPreferencesKey("imdb_ip_override")
private val YOUTUBE_API_KEY = stringPreferencesKey("youtube_api_key")

internal fun Preferences.toAppSettings(): AppSettings = AppSettings(
    defaultPage = this[DEFAULT_PAGE_KEY] ?: AppSettingsDefaults.DEFAULT_PAGE,
    resultsPerPage = this[RESULTS_PER_PAGE_KEY] ?: AppSettingsDefaults.RESULTS_PER_PAGE,
    castLimit = this[CAST_LIMIT_KEY] ?: AppSettingsDefaults.CAST_LIMIT,
    enforceHttpsForTmdb = this[ENFORCE_HTTPS_TMDB_KEY] ?: AppSettingsDefaults.ENFORCE_HTTPS_TMDB,
    enforceHttpsForImdb = this[ENFORCE_HTTPS_IMDB_KEY] ?: AppSettingsDefaults.ENFORCE_HTTPS_IMDB,
    imdbLanguageOverride = this[IMDB_LANGUAGE_KEY] ?: AppSettingsDefaults.IMDB_LANGUAGE,
    imdbIpOverride = this[IMDB_IP_OVERRIDE_KEY] ?: AppSettingsDefaults.IMDB_IP_OVERRIDE,
    youtubeApiKey = this[YOUTUBE_API_KEY] ?: AppSettingsDefaults.YOUTUBE_API_KEY
)

internal suspend fun DataStore<Preferences>.update(settings: AppSettings) {
    edit { preferences ->
        preferences[DEFAULT_PAGE_KEY] = settings.defaultPage
        preferences[RESULTS_PER_PAGE_KEY] = settings.resultsPerPage
        preferences[CAST_LIMIT_KEY] = settings.castLimit
        preferences[ENFORCE_HTTPS_TMDB_KEY] = settings.enforceHttpsForTmdb
        preferences[ENFORCE_HTTPS_IMDB_KEY] = settings.enforceHttpsForImdb
        preferences[IMDB_LANGUAGE_KEY] = settings.imdbLanguageOverride
        preferences[IMDB_IP_OVERRIDE_KEY] = settings.imdbIpOverride
        preferences[YOUTUBE_API_KEY] = settings.youtubeApiKey
    }
}

internal val DataStore<Preferences>.dataFlow: Flow<AppSettings>
    get() = data.map { it.toAppSettings() }

