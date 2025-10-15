package dev.tutushkin.allmovies.presentation.settings.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _state = MutableLiveData<SettingsState>(SettingsState.Loading)
    val state: LiveData<SettingsState> = _state

    private val _events = MutableLiveData<SettingsEvent?>()
    val events: LiveData<SettingsEvent?> = _events

    init {
        viewModelScope.launch {
            settingsRepository.settings
                .catch { throwable ->
                    _state.value = SettingsState.Error(throwable)
                }
                .collect { settings ->
                    _state.value = SettingsState.Content(settings)
                }
        }
    }

    fun save(settings: AppSettings) {
        viewModelScope.launch {
            try {
                settingsRepository.updateSettings(settings)
                _events.value = SettingsEvent.Saved
            } catch (throwable: Throwable) {
                _state.value = SettingsState.Error(throwable)
            }
        }
    }

    fun onEventConsumed() {
        _events.value = null
    }
}

