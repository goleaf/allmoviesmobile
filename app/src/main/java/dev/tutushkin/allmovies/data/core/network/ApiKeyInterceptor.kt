package dev.tutushkin.allmovies.data.core.network

import dev.tutushkin.allmovies.BuildConfig
import okhttp3.Interceptor
import okhttp3.Response

/**
 * Appends the API key query parameter required by The Movie Database to every request.
 */
class ApiKeyInterceptor : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val originalUrl = request.url

        val urlWithApiKey = originalUrl.newBuilder()
            .addQueryParameter(API_KEY_QUERY, BuildConfig.API_KEY)
            .build()

        val newRequest = request.newBuilder()
            .url(urlWithApiKey)
            .build()

        return chain.proceed(newRequest)
    }

    private companion object {
        const val API_KEY_QUERY = "api_key"
    }
}
