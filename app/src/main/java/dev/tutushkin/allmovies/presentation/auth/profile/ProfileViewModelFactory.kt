package dev.tutushkin.allmovies.presentation.auth.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.domain.auth.AuthRepository

class ProfileViewModelFactory(
    private val authRepository: AuthRepository
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ProfileViewModel::class.java)) {
            return ProfileViewModel(authRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
