package dev.tutushkin.allmovies.data.settings

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import dev.tutushkin.allmovies.domain.settings.AppSettings
import dev.tutushkin.allmovies.domain.settings.LanguageOption
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import dev.tutushkin.allmovies.domain.settings.ThemeOption
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

private const val SETTINGS_DATA_STORE = "php4dvd_user_settings"

val Context.settingsDataStore: DataStore<Preferences> by preferencesDataStore(name = SETTINGS_DATA_STORE)

class SettingsRepositoryImpl(context: Context) : SettingsRepository {

    private val appContext = context.applicationContext
    private val dataStore = appContext.settingsDataStore

    override val settings: Flow<AppSettings> = dataStore.data.map { preferences ->
        val languageCode = preferences[LANGUAGE_KEY]
        val themeKey = preferences[THEME_KEY]
        AppSettings(
            language = LanguageOption.fromPhp4DvdCode(languageCode),
            theme = ThemeOption.fromPhp4DvdKey(themeKey)
        )
    }

    override suspend fun updateLanguage(language: LanguageOption) {
        dataStore.edit { prefs ->
            prefs[LANGUAGE_KEY] = language.php4DvdCode
        }
    }

    override suspend fun updateTheme(theme: ThemeOption) {
        dataStore.edit { prefs ->
            prefs[THEME_KEY] = theme.php4DvdKey
        }
    }

    override suspend fun getSettingsSnapshot(): AppSettings {
        val preferences = dataStore.data.first()
        return AppSettings(
            language = LanguageOption.fromPhp4DvdCode(preferences[LANGUAGE_KEY]),
            theme = ThemeOption.fromPhp4DvdKey(preferences[THEME_KEY])
        )
    }

    companion object {
        private val LANGUAGE_KEY = stringPreferencesKey("language")
        private val THEME_KEY = stringPreferencesKey("theme")
    }
}
