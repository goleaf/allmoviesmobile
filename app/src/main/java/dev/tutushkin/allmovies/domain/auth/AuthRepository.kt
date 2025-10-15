package dev.tutushkin.allmovies.domain.auth

import kotlinx.coroutines.flow.Flow

interface AuthRepository {
    fun observeAuthState(): Flow<AuthState>
    fun observeAccount(): Flow<UserAccount?>
    suspend fun login(username: String, password: String): Result<UserAccount>
    suspend fun refreshSession(): Result<UserAccount>
    suspend fun logout(): Result<Unit>
    suspend fun enterGuestMode()
    suspend fun clearGuestMode()
    suspend fun requestRoles(forceRefresh: Boolean = false): Result<Set<UserRole>>
}
