package dev.tutushkin.allmovies.utils.images

enum class ConnectionType {
    UNMETERED,
    METERED,
    OFFLINE,
}

interface ConnectivityMonitor {
    fun currentConnection(): ConnectionType
}
