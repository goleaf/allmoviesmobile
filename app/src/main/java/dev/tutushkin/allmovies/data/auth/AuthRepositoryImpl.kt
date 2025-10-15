package dev.tutushkin.allmovies.data.auth

import dev.tutushkin.allmovies.data.auth.local.AuthLocalDataSource
import dev.tutushkin.allmovies.data.auth.local.StoredAccount
import dev.tutushkin.allmovies.data.auth.remote.AuthRemoteDataSource
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import dev.tutushkin.allmovies.domain.auth.AuthState
import dev.tutushkin.allmovies.domain.auth.UserAccount
import dev.tutushkin.allmovies.domain.auth.UserRole
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext

private const val SESSION_EXPIRATION_PADDING = 30_000L

class AuthRepositoryImpl(
    private val remoteDataSource: AuthRemoteDataSource,
    private val localDataSource: AuthLocalDataSource,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO
) : AuthRepository {

    override fun observeAuthState(): Flow<AuthState> =
        combine(localDataSource.observeStoredAccount(), localDataSource.observeGuestMode()) { stored, guest ->
            val account = stored?.toDomain()
            when {
                account == null && guest -> AuthState.Guest
                account == null -> AuthState.Unauthenticated
                account.isSessionExpired() -> AuthState.SessionExpired(account)
                else -> AuthState.Authenticated(account)
            }
        }

    override fun observeAccount(): Flow<UserAccount?> =
        localDataSource.observeStoredAccount().map { it?.toDomain() }

    override suspend fun login(username: String, password: String): Result<UserAccount> =
        withContext(ioDispatcher) {
            val response = remoteDataSource.login(username, password)
            response.fold(
                onSuccess = { loginResponse ->
                    val expiresAt = calculateExpiration(loginResponse.expiresInSeconds)
                    val remoteUser = loginResponse.user
                    val roles = (loginResponse.roles ?: emptyList()).toSet()
                    val storedAccount = StoredAccount(
                        id = remoteUser?.id ?: 0L,
                        username = remoteUser?.username ?: username,
                        displayName = remoteUser?.displayName,
                        roles = roles,
                        token = loginResponse.accessToken,
                        refreshToken = loginResponse.refreshToken,
                        expiresAt = expiresAt
                    )
                    localDataSource.saveAccount(storedAccount)
                    if (roles.isEmpty()) {
                        remoteDataSource.loadRoles(loginResponse.accessToken)
                            .onSuccess { localDataSource.saveRoles(it.roles.toSet()) }
                    } else {
                        localDataSource.saveRoles(roles)
                    }
                    remoteDataSource.loadProfile(loginResponse.accessToken)
                        .onSuccess { profile ->
                            localDataSource.saveAccount(
                                storedAccount.copy(
                                    username = profile.user.username,
                                    displayName = profile.user.displayName,
                                    roles = profile.roles.toSet()
                                )
                            )
                        }
                    Result.success(localDataSource.getStoredAccount()?.toDomain() ?: storedAccount.toDomain())
                },
                onFailure = { failure -> Result.failure(failure) }
            )
        }

    override suspend fun refreshSession(): Result<UserAccount> = withContext(ioDispatcher) {
        val current = localDataSource.getStoredAccount()
            ?: return@withContext Result.failure(IllegalStateException("No stored account"))
        val refreshToken = current.refreshToken
            ?: return@withContext Result.failure(IllegalStateException("Missing refresh token"))
        remoteDataSource.refresh(refreshToken).fold(
            onSuccess = { response ->
                val expiresAt = calculateExpiration(response.expiresInSeconds)
                val roles = (response.roles ?: emptyList()).toSet().ifEmpty { current.roles }
                val updatedAccount = current.copy(
                    token = response.accessToken,
                    refreshToken = response.refreshToken ?: current.refreshToken,
                    expiresAt = expiresAt,
                    roles = roles,
                    username = response.user?.username ?: current.username,
                    displayName = response.user?.displayName ?: current.displayName
                )
                localDataSource.saveAccount(updatedAccount)
                if (roles.isEmpty()) {
                    remoteDataSource.loadRoles(response.accessToken)
                        .onSuccess { localDataSource.saveRoles(it.roles.toSet()) }
                } else {
                    localDataSource.saveRoles(roles)
                }
                Result.success(updatedAccount.toDomain())
            },
            onFailure = { Result.failure(it) }
        )
    }

    override suspend fun logout(): Result<Unit> = withContext(ioDispatcher) {
        val current = localDataSource.getStoredAccount()
        val token = current?.token
        localDataSource.clearAccount()
        localDataSource.setGuestMode(false)
        if (token != null) {
            remoteDataSource.logout(token)
        } else {
            Result.success(Unit)
        }
    }

    override suspend fun enterGuestMode() {
        withContext(ioDispatcher) {
            localDataSource.setGuestMode(true)
        }
    }

    override suspend fun clearGuestMode() {
        withContext(ioDispatcher) {
            localDataSource.setGuestMode(false)
        }
    }

    override suspend fun requestRoles(forceRefresh: Boolean): Result<Set<UserRole>> =
        withContext(ioDispatcher) {
            val account = localDataSource.getStoredAccount()
                ?: return@withContext Result.success(emptySet())
            val cachedRoles = account.roles
            if (cachedRoles.isNotEmpty() && !forceRefresh) {
                return@withContext Result.success(cachedRoles.toDomainRoles())
            }
            remoteDataSource.loadRoles(account.token).fold(
                onSuccess = {
                    val roles = it.roles.toSet()
                    localDataSource.saveRoles(roles)
                    Result.success(roles.toDomainRoles())
                },
                onFailure = { failure -> Result.failure(failure) }
            )
        }

    private fun calculateExpiration(expiresInSeconds: Long): Long {
        val duration = if (expiresInSeconds <= 0) 0 else expiresInSeconds * 1000
        return if (duration == 0L) 0 else System.currentTimeMillis() + duration - SESSION_EXPIRATION_PADDING
    }

    private fun Set<String>.toDomainRoles(): Set<UserRole> =
        map { UserRole.fromRemote(it) }.toSet()

    private fun StoredAccount.toDomain(): UserAccount = UserAccount(
        id = id,
        username = username,
        displayName = displayName,
        roles = roles.toDomainRoles(),
        token = token,
        refreshToken = refreshToken,
        expiresAtMillis = expiresAt
    )
}
