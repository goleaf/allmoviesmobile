package dev.tutushkin.allmovies.data.core.network

import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import dev.tutushkin.allmovies.domain.settings.models.AppSettingsDefaults
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import okhttp3.Interceptor
import okhttp3.Response
import java.util.concurrent.atomic.AtomicReference

class SettingsInterceptor(
    settingsFlow: Flow<AppSettings>
) : Interceptor {

    private val latestSettings = AtomicReference(AppSettingsDefaults.default())
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    init {
        scope.launch {
            settingsFlow.collectLatest { settings ->
                latestSettings.set(settings)
            }
        }
    }

    override fun intercept(chain: Interceptor.Chain): Response {
        val settings = latestSettings.get()
        var request = chain.request()
        val originalUrl = request.url

        val adjustedUrl = when {
            originalUrl.host.contains("themoviedb") -> adjustScheme(originalUrl, settings.enforceHttpsForTmdb)
            originalUrl.host.contains("imdb") -> adjustScheme(originalUrl, settings.enforceHttpsForImdb)
            else -> originalUrl
        }

        if (adjustedUrl != originalUrl) {
            request = request.newBuilder().url(adjustedUrl).build()
        }

        if (adjustedUrl.host.contains("imdb")) {
            val builder = request.newBuilder()
            if (settings.imdbLanguageOverride.isNotBlank()) {
                builder.header("Accept-Language", settings.imdbLanguageOverride)
            }
            if (settings.imdbIpOverride.isNotBlank()) {
                builder.header("X-Forwarded-For", settings.imdbIpOverride)
            }
            request = builder.build()
        }

        return chain.proceed(request)
    }

    private fun adjustScheme(url: okhttp3.HttpUrl, enforceHttps: Boolean): okhttp3.HttpUrl {
        return when {
            enforceHttps && url.scheme != "https" -> url.newBuilder().scheme("https").build()
            !enforceHttps && url.scheme != "http" -> url.newBuilder().scheme("http").build()
            else -> url
        }
    }
}

