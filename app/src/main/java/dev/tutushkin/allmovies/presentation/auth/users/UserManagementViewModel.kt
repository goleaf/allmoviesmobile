package dev.tutushkin.allmovies.presentation.auth.users

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import dev.tutushkin.allmovies.domain.auth.UserAccount
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class UserManagementViewModel(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableLiveData<UserManagementUiState>(UserManagementUiState.Loading)
    val state: LiveData<UserManagementUiState> = _state

    private var lastAccount: UserAccount? = null

    init {
        observeAccount()
    }

    private fun observeAccount() {
        viewModelScope.launch {
            authRepository.observeAccount().collect { account ->
                when {
                    account == null -> {
                        _state.postValue(UserManagementUiState.AccessDenied)
                        lastAccount = null
                    }
                    !account.canManageUsers() -> {
                        _state.postValue(UserManagementUiState.AccessDenied)
                        lastAccount = account
                    }
                    shouldReload(account) -> {
                        lastAccount = account
                        loadRoles()
                    }
                }
            }
        }
    }

    private fun shouldReload(account: UserAccount): Boolean {
        val previous = lastAccount
        return previous == null || previous.id != account.id || previous.roles != account.roles
    }

    private suspend fun loadRoles() {
        _state.postValue(UserManagementUiState.Loading)
        val result = authRepository.requestRoles(forceRefresh = true)
        _state.postValue(
            if (result.isSuccess) {
                val roles = result.getOrDefault(emptySet()).map { it.name }
                UserManagementUiState.Data(roles)
            } else {
                UserManagementUiState.Error(result.exceptionOrNull()?.message ?: "Unable to load roles")
            }
        )
    }
}

sealed class UserManagementUiState {
    object Loading : UserManagementUiState()
    object AccessDenied : UserManagementUiState()
    data class Data(val roles: List<String>) : UserManagementUiState()
    data class Error(val message: String) : UserManagementUiState()
}
