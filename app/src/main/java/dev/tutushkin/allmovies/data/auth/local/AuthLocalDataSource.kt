package dev.tutushkin.allmovies.data.auth.local

import kotlinx.coroutines.flow.Flow

interface AuthLocalDataSource {
    fun observeStoredAccount(): Flow<StoredAccount?>
    fun observeGuestMode(): Flow<Boolean>
    suspend fun getStoredAccount(): StoredAccount?
    suspend fun saveAccount(account: StoredAccount)
    suspend fun saveRoles(roles: Set<String>)
    suspend fun updateTokens(token: String, refreshToken: String?, expiresAt: Long)
    suspend fun clearAccount()
    suspend fun setGuestMode(enabled: Boolean)
}

data class StoredAccount(
    val id: Long,
    val username: String,
    val displayName: String?,
    val roles: Set<String>,
    val token: String,
    val refreshToken: String?,
    val expiresAt: Long
)
