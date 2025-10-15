package dev.tutushkin.allmovies.presentation.settings.viewmodel

import dev.tutushkin.allmovies.domain.settings.models.AppSettings

sealed class SettingsState {
    object Loading : SettingsState()
    data class Content(val settings: AppSettings) : SettingsState()
    data class Error(val error: Throwable) : SettingsState()
}

