package dev.tutushkin.allmovies.data.preferences

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import dev.tutushkin.allmovies.domain.movies.models.LayoutMode
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.searchPreferences by preferencesDataStore(name = "search_settings")

class SearchPreferencesDataSource(private val context: Context) {

    private val layoutModeKey = stringPreferencesKey("layout_mode")
    private val pageSizeKey = intPreferencesKey("page_size")

    val layoutModeFlow: Flow<LayoutMode> = context.searchPreferences.data
        .map { preferences ->
            preferences[layoutModeKey]?.let {
                runCatching { LayoutMode.valueOf(it) }.getOrDefault(LayoutMode.POSTER)
            } ?: LayoutMode.POSTER
        }

    val pageSizeFlow: Flow<Int> = context.searchPreferences.data
        .map { preferences ->
            preferences[pageSizeKey] ?: DEFAULT_PAGE_SIZE
        }

    suspend fun setLayoutMode(layoutMode: LayoutMode) {
        context.searchPreferences.edit { preferences ->
            preferences[layoutModeKey] = layoutMode.name
        }
    }

    suspend fun setPageSize(pageSize: Int) {
        context.searchPreferences.edit { preferences ->
            preferences[pageSizeKey] = pageSize
        }
    }

    companion object {
        private const val DEFAULT_PAGE_SIZE = 20
    }
}
