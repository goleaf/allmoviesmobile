package dev.tutushkin.allmovies.presentation

import dev.tutushkin.allmovies.data.settings.LanguagePreferencesDataSource

class TestLanguagePreferences(
    private var language: String = "en"
) : LanguagePreferencesDataSource {

    override fun getSelectedLanguage(): String = language

    override fun setSelectedLanguage(code: String) {
        language = code
    }
}
