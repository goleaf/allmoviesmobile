package dev.tutushkin.allmovies.domain.auth

data class UserAccount(
    val id: Long,
    val username: String,
    val displayName: String?,
    val roles: Set<UserRole>,
    val token: String,
    val refreshToken: String?,
    val expiresAtMillis: Long
) {

    fun isSessionExpired(currentTimeMillis: Long = System.currentTimeMillis()): Boolean =
        expiresAtMillis in 1..Long.MAX_VALUE && currentTimeMillis >= expiresAtMillis

    fun canViewCollection(): Boolean = roles.isNotEmpty() && roles.none { it == UserRole.GUEST }

    fun canManageUsers(): Boolean = roles.contains(UserRole.ADMIN)

    fun canModifyCollection(): Boolean = roles.any { it == UserRole.ADMIN || it == UserRole.EDITOR }
}
