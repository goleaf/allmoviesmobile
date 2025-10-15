package dev.tutushkin.allmovies.data.auth.local

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

class AuthLocalDataSourceImpl(
    private val dataStore: DataStore<Preferences>
) : AuthLocalDataSource {

    private val keyId = longPreferencesKey("user_id")
    private val keyUsername = stringPreferencesKey("user_username")
    private val keyDisplayName = stringPreferencesKey("user_display_name")
    private val keyRoles = stringSetPreferencesKey("user_roles")
    private val keyToken = stringPreferencesKey("user_token")
    private val keyRefresh = stringPreferencesKey("user_refresh_token")
    private val keyExpiresAt = longPreferencesKey("user_expires_at")
    private val keyGuest = booleanPreferencesKey("guest_mode")

    override fun observeStoredAccount(): Flow<StoredAccount?> =
        dataStore.data.map { prefs ->
            val token = prefs[keyToken]
            val id = prefs[keyId]
            if (token.isNullOrBlank() || id == null) {
                null
            } else {
                val displayName = prefs[keyDisplayName]?.takeIf { it.isNotBlank() }
                val refreshToken = prefs[keyRefresh]?.takeIf { it.isNotBlank() }
                StoredAccount(
                    id = id,
                    username = prefs[keyUsername].orEmpty(),
                    displayName = displayName,
                    roles = prefs[keyRoles] ?: emptySet(),
                    token = token,
                    refreshToken = refreshToken,
                    expiresAt = prefs[keyExpiresAt] ?: 0L
                )
            }
        }

    override fun observeGuestMode(): Flow<Boolean> =
        dataStore.data.map { prefs -> prefs[keyGuest] ?: false }

    override suspend fun getStoredAccount(): StoredAccount? = observeStoredAccount().first()

    override suspend fun saveAccount(account: StoredAccount) {
        dataStore.edit { prefs ->
            prefs[keyId] = account.id
            prefs[keyUsername] = account.username
            if (account.displayName.isNullOrBlank()) {
                prefs.remove(keyDisplayName)
            } else {
                prefs[keyDisplayName] = account.displayName
            }
            prefs[keyRoles] = account.roles
            prefs[keyToken] = account.token
            if (account.refreshToken.isNullOrBlank()) {
                prefs.remove(keyRefresh)
            } else {
                prefs[keyRefresh] = account.refreshToken
            }
            prefs[keyExpiresAt] = account.expiresAt
            prefs[keyGuest] = false
        }
    }

    override suspend fun saveRoles(roles: Set<String>) {
        dataStore.edit { prefs ->
            if (roles.isEmpty()) {
                prefs.remove(keyRoles)
            } else {
                prefs[keyRoles] = roles
            }
        }
    }

    override suspend fun updateTokens(token: String, refreshToken: String?, expiresAt: Long) {
        dataStore.edit { prefs ->
            prefs[keyToken] = token
            if (refreshToken != null) {
                prefs[keyRefresh] = refreshToken
            }
            prefs[keyExpiresAt] = expiresAt
        }
    }

    override suspend fun clearAccount() {
        dataStore.edit { prefs ->
            prefs.remove(keyId)
            prefs.remove(keyUsername)
            prefs.remove(keyDisplayName)
            prefs.remove(keyRoles)
            prefs.remove(keyToken)
            prefs.remove(keyRefresh)
            prefs.remove(keyExpiresAt)
        }
    }

    override suspend fun setGuestMode(enabled: Boolean) {
        dataStore.edit { prefs ->
            prefs[keyGuest] = enabled
            if (enabled) {
                prefs.remove(keyId)
                prefs.remove(keyUsername)
                prefs.remove(keyDisplayName)
                prefs.remove(keyRoles)
                prefs.remove(keyToken)
                prefs.remove(keyRefresh)
                prefs.remove(keyExpiresAt)
            }
        }
    }
}
