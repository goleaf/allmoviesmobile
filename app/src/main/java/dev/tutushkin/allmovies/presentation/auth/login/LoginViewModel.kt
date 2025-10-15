package dev.tutushkin.allmovies.presentation.auth.login

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import kotlinx.coroutines.launch

class LoginViewModel(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableLiveData<LoginUiState>(LoginUiState.Idle)
    val state: LiveData<LoginUiState> = _state

    fun login(username: String, password: String) {
        if (username.isBlank() || password.isBlank()) {
            _state.value = LoginUiState.Error("Username and password are required")
            return
        }
        viewModelScope.launch {
            _state.value = LoginUiState.Loading
            authRepository.clearGuestMode()
            val result = authRepository.login(username.trim(), password)
            _state.value = if (result.isSuccess) {
                LoginUiState.Success
            } else {
                LoginUiState.Error(result.exceptionOrNull()?.message ?: "Unable to login")
            }
        }
    }

    fun continueAsGuest() {
        viewModelScope.launch {
            authRepository.enterGuestMode()
            _state.value = LoginUiState.Guest
        }
    }

    fun resetState() {
        _state.value = LoginUiState.Idle
    }
}

sealed class LoginUiState {
    object Idle : LoginUiState()
    object Loading : LoginUiState()
    object Success : LoginUiState()
    object Guest : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}
