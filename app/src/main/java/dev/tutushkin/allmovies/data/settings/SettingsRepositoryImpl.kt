package dev.tutushkin.allmovies.data.settings

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import dev.tutushkin.allmovies.data.settings.local.dataFlow
import dev.tutushkin.allmovies.data.settings.local.update
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import dev.tutushkin.allmovies.domain.settings.models.AppSettingsDefaults
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext

class SettingsRepositoryImpl(
    private val dataStore: DataStore<Preferences>,
    private val ioDispatcher: CoroutineDispatcher
) : SettingsRepository {

    override val settings: Flow<AppSettings> = dataStore.dataFlow

    override suspend fun getSettings(): AppSettings = settings.first()

    override suspend fun updateSettings(settings: AppSettings) {
        val sanitized = settings.sanitized()
        withContext(ioDispatcher) {
            dataStore.update(sanitized)
        }
    }

    private fun AppSettings.sanitized(): AppSettings {
        val trimmedLanguage = imdbLanguageOverride.trim()
        val trimmedIp = imdbIpOverride.trim()
        return AppSettings(
            defaultPage = defaultPage.coerceAtLeast(1),
            resultsPerPage = resultsPerPage.coerceAtLeast(1),
            castLimit = castLimit.coerceAtLeast(0),
            enforceHttpsForTmdb = enforceHttpsForTmdb,
            enforceHttpsForImdb = enforceHttpsForImdb,
            imdbLanguageOverride = trimmedLanguage.ifBlank { AppSettingsDefaults.IMDB_LANGUAGE },
            imdbIpOverride = trimmedIp,
            youtubeApiKey = youtubeApiKey.trim()
        )
    }
}

