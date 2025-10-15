package dev.tutushkin.allmovies.data.core.network

import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.data.movies.remote.MoviesApi
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.create
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.runBlocking

// TODO Implement Api Key through the interceptor
// TODO Get off singleton
object NetworkModule {

    var allGenres: List<Genre> = listOf()

    // TODO Move to DataStore(?)
    var configApi: Configuration = Configuration()

    private val json = Json {
        prettyPrint = true
        ignoreUnknownKeys = true
    }

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val contentType = "application/json".toMediaType()

    @ExperimentalSerializationApi
    fun createMoviesApi(settingsRepository: SettingsRepository): MoviesApi {
        val initialSettings = runBlocking { settingsRepository.getSettings() }
        val client = createClient(settingsRepository)
        val baseUrl = BuildConfig.BASE_URL.ensureScheme(initialSettings.enforceHttpsForTmdb)

        val retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(json.asConverterFactory(contentType))
            .build()

        return retrofit.create()
    }

    private fun createClient(settingsRepository: SettingsRepository): OkHttpClient {
        val settingsInterceptor = SettingsInterceptor(settingsRepository.settings)
        return OkHttpClient().newBuilder()
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(10, TimeUnit.SECONDS)
            .writeTimeout(10, TimeUnit.SECONDS)
            .addInterceptor(settingsInterceptor)
            .addInterceptor(loggingInterceptor)
            .addNetworkInterceptor(loggingInterceptor)
            .build()
    }

    private fun String.ensureScheme(enforceHttps: Boolean): String {
        return if (enforceHttps) {
            if (startsWith("http://")) {
                replaceFirst("http://", "https://")
            } else {
                this
            }
        } else {
            if (startsWith("https://")) {
                replaceFirst("https://", "http://")
            } else {
                this
            }
        }
    }
}
