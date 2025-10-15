package dev.tutushkin.allmovies.data.auth.remote

import dev.tutushkin.allmovies.data.auth.model.LoginRequest
import dev.tutushkin.allmovies.data.auth.model.LoginResponse
import dev.tutushkin.allmovies.data.auth.model.ProfileResponse
import dev.tutushkin.allmovies.data.auth.model.RefreshRequest
import dev.tutushkin.allmovies.data.auth.model.RolesResponse
import dev.tutushkin.allmovies.data.auth.network.AuthApi

class AuthRemoteDataSourceImpl(
    private val authApi: AuthApi
) : AuthRemoteDataSource {

    override suspend fun login(username: String, password: String): Result<LoginResponse> =
        runCatching {
            authApi.login(LoginRequest(username = username, password = password))
        }

    override suspend fun refresh(refreshToken: String): Result<LoginResponse> =
        runCatching {
            authApi.refresh(RefreshRequest(refreshToken))
        }

    override suspend fun loadProfile(token: String): Result<ProfileResponse> =
        runCatching {
            authApi.getProfile("Bearer $token")
        }

    override suspend fun loadRoles(token: String): Result<RolesResponse> =
        runCatching {
            authApi.getRoles("Bearer $token")
        }

    override suspend fun logout(token: String): Result<Unit> =
        runCatching {
            authApi.logout("Bearer $token")
        }
}
