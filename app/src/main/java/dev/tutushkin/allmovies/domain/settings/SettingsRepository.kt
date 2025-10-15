package dev.tutushkin.allmovies.domain.settings

import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    val settings: Flow<AppSettings>

    suspend fun updateLanguage(language: LanguageOption)

    suspend fun updateTheme(theme: ThemeOption)

    suspend fun getSettingsSnapshot(): AppSettings
}
