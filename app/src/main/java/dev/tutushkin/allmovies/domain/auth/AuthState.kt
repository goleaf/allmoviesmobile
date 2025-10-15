package dev.tutushkin.allmovies.domain.auth

sealed class AuthState {
    object Unauthenticated : AuthState()
    object Guest : AuthState()
    data class Authenticated(val account: UserAccount) : AuthState()
    data class SessionExpired(val account: UserAccount) : AuthState()
}
