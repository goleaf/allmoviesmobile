package dev.tutushkin.allmovies.domain.settings

import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    val settings: Flow<AppSettings>

    suspend fun getSettings(): AppSettings

    suspend fun updateSettings(settings: AppSettings)
}

