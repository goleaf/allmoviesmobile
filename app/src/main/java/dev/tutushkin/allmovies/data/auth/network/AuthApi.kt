package dev.tutushkin.allmovies.data.auth.network

import dev.tutushkin.allmovies.data.auth.model.LoginRequest
import dev.tutushkin.allmovies.data.auth.model.LoginResponse
import dev.tutushkin.allmovies.data.auth.model.ProfileResponse
import dev.tutushkin.allmovies.data.auth.model.RefreshRequest
import dev.tutushkin.allmovies.data.auth.model.RolesResponse
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST

interface AuthApi {
    @POST("sessions")
    suspend fun login(@Body request: LoginRequest): LoginResponse

    @POST("sessions/refresh")
    suspend fun refresh(@Body request: RefreshRequest): LoginResponse

    @GET("users/me")
    suspend fun getProfile(@Header("Authorization") authorization: String): ProfileResponse

    @GET("users/me/roles")
    suspend fun getRoles(@Header("Authorization") authorization: String): RolesResponse

    @POST("sessions/logout")
    suspend fun logout(@Header("Authorization") authorization: String)
}
