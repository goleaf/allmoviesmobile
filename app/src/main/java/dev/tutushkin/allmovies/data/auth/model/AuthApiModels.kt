package dev.tutushkin.allmovies.data.auth.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class LoginRequest(
    val username: String,
    val password: String
)

@Serializable
data class RefreshRequest(
    @SerialName("refresh_token")
    val refreshToken: String
)

@Serializable
data class LoginResponse(
    @SerialName("access_token")
    val accessToken: String,
    @SerialName("refresh_token")
    val refreshToken: String? = null,
    @SerialName("expires_in")
    val expiresInSeconds: Long = 0,
    val user: RemoteUser? = null,
    val roles: List<String>? = null
)

@Serializable
data class RemoteUser(
    val id: Long,
    @SerialName("username")
    val username: String,
    @SerialName("display_name")
    val displayName: String? = null
)

@Serializable
data class RolesResponse(
    val roles: List<String>
)

@Serializable
data class ProfileResponse(
    val user: RemoteUser,
    val roles: List<String> = emptyList()
)
