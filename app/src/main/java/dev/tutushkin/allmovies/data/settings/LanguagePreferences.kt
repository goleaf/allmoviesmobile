package dev.tutushkin.allmovies.data.settings

import android.content.Context
import android.content.SharedPreferences
import java.util.Locale

class LanguagePreferences(context: Context) {

    private val preferences: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun getSelectedLanguage(): String {
        return preferences.getString(KEY_SELECTED_LANGUAGE, null)
            ?.takeIf { it.isNotBlank() }
            ?: Locale.getDefault().language
    }

    fun setSelectedLanguage(code: String) {
        preferences.edit().putString(KEY_SELECTED_LANGUAGE, code).apply()
    }

    companion object {
        private const val PREFS_NAME = "allmovies_language_preferences"
        private const val KEY_SELECTED_LANGUAGE = "selected_language"
    }
}
