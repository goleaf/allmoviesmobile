package dev.tutushkin.allmovies.data.auth.remote

import dev.tutushkin.allmovies.data.auth.model.LoginResponse
import dev.tutushkin.allmovies.data.auth.model.ProfileResponse
import dev.tutushkin.allmovies.data.auth.model.RolesResponse

interface AuthRemoteDataSource {
    suspend fun login(username: String, password: String): Result<LoginResponse>
    suspend fun refresh(refreshToken: String): Result<LoginResponse>
    suspend fun loadProfile(token: String): Result<ProfileResponse>
    suspend fun loadRoles(token: String): Result<RolesResponse>
    suspend fun logout(token: String): Result<Unit>
}
