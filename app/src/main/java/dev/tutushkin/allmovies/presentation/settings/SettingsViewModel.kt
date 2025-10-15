package dev.tutushkin.allmovies.presentation.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.settings.AppSettings
import dev.tutushkin.allmovies.domain.settings.LanguageOption
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import dev.tutushkin.allmovies.domain.settings.ThemeOption
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class SettingsViewModel(private val repository: SettingsRepository) : ViewModel() {

    private val _state = MutableStateFlow(AppSettings(LanguageOption.EN, ThemeOption.DEFAULT))
    val state: StateFlow<AppSettings> = _state.asStateFlow()

    init {
        viewModelScope.launch {
            _state.value = repository.getSettingsSnapshot()
            repository.settings.collect { settings ->
                _state.value = settings
            }
        }
    }

    fun onLanguageSelected(language: LanguageOption) {
        viewModelScope.launch {
            repository.updateLanguage(language)
        }
    }

    fun onThemeSelected(theme: ThemeOption) {
        viewModelScope.launch {
            repository.updateTheme(theme)
        }
    }
}

class SettingsViewModelFactory(private val repository: SettingsRepository) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(SettingsViewModel::class.java)) {
            return SettingsViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
