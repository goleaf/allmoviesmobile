package dev.tutushkin.allmovies.data.movies.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import java.io.IOException
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

val Context.configurationPreferencesDataStore: DataStore<Preferences> by preferencesDataStore(
    name = "tmdb_configuration"
)

class ConfigurationDataStore(
    private val dataStore: DataStore<Preferences>,
    private val json: Json = Json { ignoreUnknownKeys = true }
) {

    suspend fun read(): Configuration? {
        val preferences = dataStore.data
            .catch { exception ->
                if (exception is IOException) {
                    emit(emptyPreferences())
                } else {
                    throw exception
                }
            }
            .first()

        val raw = preferences[CONFIGURATION_KEY] ?: return null

        return runCatching {
            json.decodeFromString<StoredConfiguration>(raw).toDomain()
        }.getOrNull()
    }

    suspend fun readOrDefault(): Configuration = read() ?: Configuration()

    suspend fun write(configuration: Configuration) {
        val serialized = json.encodeToString(StoredConfiguration.from(configuration))
        dataStore.edit { prefs ->
            prefs[CONFIGURATION_KEY] = serialized
        }
    }

    private companion object {
        val CONFIGURATION_KEY = stringPreferencesKey("configuration_json")
    }
}

@Serializable
private data class StoredConfiguration(
    val imagesBaseUrl: String,
    val posterSizes: List<String>,
    val backdropSizes: List<String>,
    val profileSizes: List<String>,
) {
    fun toDomain(): Configuration = Configuration(
        imagesBaseUrl = imagesBaseUrl,
        posterSizes = posterSizes,
        backdropSizes = backdropSizes,
        profileSizes = profileSizes,
    )

    companion object {
        fun from(configuration: Configuration): StoredConfiguration = StoredConfiguration(
            imagesBaseUrl = configuration.imagesBaseUrl,
            posterSizes = configuration.posterSizes,
            backdropSizes = configuration.backdropSizes,
            profileSizes = configuration.profileSizes,
        )
    }
}
