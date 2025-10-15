package dev.tutushkin.allmovies.presentation.auth.settings

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableLiveData<SettingsUiState>(SettingsUiState.Idle)
    val state: LiveData<SettingsUiState> = _state

    fun refreshSession() {
        viewModelScope.launch {
            _state.value = SettingsUiState.Loading
            val result = authRepository.refreshSession()
            _state.value = if (result.isSuccess) {
                SettingsUiState.SessionRefreshed
            } else {
                SettingsUiState.Error(result.exceptionOrNull()?.message ?: "Unable to refresh session")
            }
        }
    }

    fun logout() {
        viewModelScope.launch {
            _state.value = SettingsUiState.Loading
            val result = authRepository.logout()
            _state.value = if (result.isSuccess) {
                SettingsUiState.LoggedOut
            } else {
                SettingsUiState.Error(result.exceptionOrNull()?.message ?: "Unable to logout")
            }
        }
    }

    fun resetState() {
        _state.value = SettingsUiState.Idle
    }
}

sealed class SettingsUiState {
    object Idle : SettingsUiState()
    object Loading : SettingsUiState()
    object SessionRefreshed : SettingsUiState()
    object LoggedOut : SettingsUiState()
    data class Error(val message: String) : SettingsUiState()
}
