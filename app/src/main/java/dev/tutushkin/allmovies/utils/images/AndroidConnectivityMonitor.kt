package dev.tutushkin.allmovies.utils.images

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import androidx.core.content.ContextCompat

class AndroidConnectivityMonitor(context: Context) : ConnectivityMonitor {

    private val appContext = context.applicationContext

    override fun currentConnection(): ConnectionType {
        val connectivityManager = ContextCompat.getSystemService(
            appContext,
            ConnectivityManager::class.java
        ) ?: return ConnectionType.OFFLINE

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = connectivityManager.activeNetwork ?: return ConnectionType.OFFLINE
            val capabilities = connectivityManager.getNetworkCapabilities(network)
                ?: return ConnectionType.OFFLINE
            when {
                capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) -> ConnectionType.UNMETERED
                capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) -> ConnectionType.METERED
                else -> ConnectionType.OFFLINE
            }
        } else {
            @Suppress("DEPRECATION")
            val networkInfo = connectivityManager.activeNetworkInfo ?: return ConnectionType.OFFLINE
            if (!networkInfo.isConnected) {
                return ConnectionType.OFFLINE
            }
            val isMetered = connectivityManager.isActiveNetworkMetered
            if (isMetered) ConnectionType.METERED else ConnectionType.UNMETERED
        }
    }
}
