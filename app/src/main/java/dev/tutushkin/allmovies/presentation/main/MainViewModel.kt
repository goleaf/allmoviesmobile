package dev.tutushkin.allmovies.presentation.main

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import dev.tutushkin.allmovies.domain.auth.AuthState
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch

class MainViewModel(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _authState = MutableLiveData<AuthState>()
    val authState: LiveData<AuthState> = _authState

    private val _toolbarState = MutableLiveData<ToolbarState>()
    val toolbarState: LiveData<ToolbarState> = _toolbarState

    private val _events = MutableSharedFlow<MainEvent>()
    val events = _events.asSharedFlow()

    private var sessionExpirationHandled = false

    init {
        observeAuthState()
    }

    private fun observeAuthState() {
        viewModelScope.launch {
            authRepository.observeAuthState().collect { state ->
                _authState.postValue(state)
                _toolbarState.postValue(ToolbarState.fromAuthState(state))
                if (state is AuthState.SessionExpired && !sessionExpirationHandled) {
                    sessionExpirationHandled = true
                    _events.emit(MainEvent.SessionExpired)
                    authRepository.logout()
                }
                if (state !is AuthState.SessionExpired) {
                    sessionExpirationHandled = false
                }
            }
        }
    }

    fun requestLogout() {
        viewModelScope.launch {
            authRepository.logout()
        }
    }

    fun refreshSession() {
        viewModelScope.launch {
            authRepository.refreshSession()
        }
    }
}

sealed class MainEvent {
    object SessionExpired : MainEvent()
}

data class ToolbarState(
    val showProfile: Boolean,
    val showSettings: Boolean,
    val showUserManagement: Boolean,
    val showLogout: Boolean
) {
    companion object {
        fun fromAuthState(state: AuthState): ToolbarState = when (state) {
            AuthState.Guest, AuthState.Unauthenticated -> ToolbarState(
                showProfile = false,
                showSettings = false,
                showUserManagement = false,
                showLogout = false
            )
            is AuthState.Authenticated -> ToolbarState(
                showProfile = true,
                showSettings = true,
                showUserManagement = state.account.canManageUsers(),
                showLogout = true
            )
            is AuthState.SessionExpired -> ToolbarState(
                showProfile = false,
                showSettings = false,
                showUserManagement = false,
                showLogout = false
            )
        }
    }
}
