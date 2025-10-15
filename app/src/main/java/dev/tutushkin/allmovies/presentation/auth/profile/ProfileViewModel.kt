package dev.tutushkin.allmovies.presentation.auth.profile

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import dev.tutushkin.allmovies.domain.auth.UserAccount
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class ProfileViewModel(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _profile = MutableLiveData<ProfileUiState>(ProfileUiState.Empty)
    val profile: LiveData<ProfileUiState> = _profile

    init {
        observeAccount()
    }

    private fun observeAccount() {
        viewModelScope.launch {
            authRepository.observeAccount().collect { account ->
                _profile.postValue(account?.toUiState() ?: ProfileUiState.Empty)
            }
        }
    }

    private fun UserAccount.toUiState(): ProfileUiState = ProfileUiState.Data(
        displayName = displayName ?: username,
        username = username,
        roles = roles.joinToString(separator = ", ") { it.name.lowercase().replaceFirstChar(Char::uppercase) }
    )
}

sealed class ProfileUiState {
    object Empty : ProfileUiState()
    data class Data(
        val displayName: String,
        val username: String,
        val roles: String
    ) : ProfileUiState()
}
