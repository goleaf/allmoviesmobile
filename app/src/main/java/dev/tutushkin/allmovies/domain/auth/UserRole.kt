package dev.tutushkin.allmovies.domain.auth

enum class UserRole {
    ADMIN,
    EDITOR,
    VIEWER,
    GUEST;

    companion object {
        fun fromRemote(name: String): UserRole = when (name.uppercase()) {
            "ADMIN", "ROLE_ADMIN" -> ADMIN
            "EDITOR", "ROLE_EDITOR" -> EDITOR
            "VIEWER", "ROLE_VIEWER" -> VIEWER
            "GUEST", "ROLE_GUEST" -> GUEST
            else -> VIEWER
        }
    }
}
