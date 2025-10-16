package dev.tutushkin.allmovies.data.movies.local

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.mutablePreferencesOf
import androidx.datastore.preferences.core.stringPreferencesKey
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ConfigurationDataStoreTest {

    private val dataStore = InMemoryPreferencesDataStore()
    private val configurationDataStore = ConfigurationDataStore(dataStore)

    @Test
    fun `read returns null when configuration absent`() = runTest {
        val result = configurationDataStore.read()

        assertNull(result)
    }

    @Test
    fun `write persists configuration for future reads`() = runTest {
        val configuration = Configuration(
            imagesBaseUrl = "https://example.com/",
            posterSizes = listOf("w500"),
            backdropSizes = listOf("w1280"),
            profileSizes = listOf("w300")
        )

        configurationDataStore.write(configuration)

        val stored = configurationDataStore.read()
        assertEquals(configuration, stored)
    }

    @Test
    fun `readOrDefault falls back when stored data corrupt`() = runTest {
        val key = stringPreferencesKey("configuration_json")
        dataStore.updateData { mutablePreferencesOf(key to "{invalid}") }

        val configuration = configurationDataStore.readOrDefault()

        assertEquals(Configuration(), configuration)
    }

    private class InMemoryPreferencesDataStore(
        initialPreferences: Preferences = emptyPreferences()
    ) : DataStore<Preferences> {

        private val state = MutableStateFlow(initialPreferences)

        override val data: Flow<Preferences> = state

        override suspend fun updateData(transform: suspend (t: Preferences) -> Preferences): Preferences {
            val updated = transform(state.value)
            state.value = updated
            return updated
        }
    }
}
