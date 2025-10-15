package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "movie_details")
data class MovieDetailsEntity(

    @PrimaryKey
    @ColumnInfo(name = "id")
    val id: Int,

    @ColumnInfo(name = "title")
    val title: String,

    @ColumnInfo(name = "overview")
    val overview: String,

    @ColumnInfo(name = "backdrop")
    val backdrop: String,

    @ColumnInfo(name = "ratings")
    val ratings: Float,

    @ColumnInfo(name = "numberOfRatings")
    val numberOfRatings: Int,

    @ColumnInfo(name = "minimumAge")
    val minimumAge: String,

    @ColumnInfo(name = "year")
    val year: String,

    @ColumnInfo(name = "runtime")
    val runtime: Int = 0,

    @ColumnInfo(name = "genres")
    val genres: String,

    @ColumnInfo(name = "actors")
    var actors: List<Int> = listOf(),

    @ColumnInfo(name = "isActorsLoaded")
    val isActorsLoaded: Boolean = false,

    @ColumnInfo(name = "directors")
    val directors: List<String> = emptyList(),

    @ColumnInfo(name = "writers")
    val writers: List<String> = emptyList(),

    @ColumnInfo(name = "languages")
    val languages: List<String> = emptyList(),

    @ColumnInfo(name = "subtitles")
    val subtitles: List<String> = emptyList(),

    @ColumnInfo(name = "audio_tracks")
    val audioTracks: List<String> = emptyList(),

    @ColumnInfo(name = "video_formats")
    val videoFormats: List<String> = emptyList(),

    @ColumnInfo(name = "trailers")
    val trailerUrls: List<String> = emptyList()
)
