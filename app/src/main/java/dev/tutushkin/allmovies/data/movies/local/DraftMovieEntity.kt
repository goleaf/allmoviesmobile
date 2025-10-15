package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "draft_movies")
data class DraftMovieEntity(
    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "id")
    val id: Long = 0L,
    @ColumnInfo(name = "title")
    val title: String,
    @ColumnInfo(name = "title_order")
    val titleOrder: String,
    @ColumnInfo(name = "aka_titles")
    val akaTitles: List<String>,
    @ColumnInfo(name = "duration_minutes")
    val durationMinutes: Int?,
    @ColumnInfo(name = "formats")
    val formats: List<String>,
    @ColumnInfo(name = "mpaa_rating")
    val mpaaRating: String,
    @ColumnInfo(name = "cast")
    val cast: List<String>,
    @ColumnInfo(name = "crew")
    val crew: List<String>,
    @ColumnInfo(name = "trailer_url")
    val trailerUrl: String,
    @ColumnInfo(name = "release_date")
    val releaseDate: String,
    @ColumnInfo(name = "personal_notes")
    val personalNotes: String,
    @ColumnInfo(name = "imdb_id")
    val imdbId: String?,
    @ColumnInfo(name = "cover_uri")
    val coverUri: String?,
    @ColumnInfo(name = "created_at")
    val createdAt: Long,
    @ColumnInfo(name = "updated_at")
    val updatedAt: Long
)
