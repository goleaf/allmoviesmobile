package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "movies")
data class MovieListEntity(

    @PrimaryKey
    @ColumnInfo(name = "id")
    val id: Int,

    @ColumnInfo(name = "title")
    val title: String,

    @ColumnInfo(name = "poster")
    val poster: String,

    @ColumnInfo(name = "ratings")
    val ratings: Float,

    @ColumnInfo(name = "numberOfRatings")
    val numberOfRatings: Int,

    @ColumnInfo(name = "minimumAge")
    val minimumAge: String,

    @ColumnInfo(name = "year")
    val year: String,

    @ColumnInfo(name = "genres")
    val genres: String,

    @ColumnInfo(name = "genre_ids")
    val genreIds: String = "",

    @ColumnInfo(name = "is_tv_show")
    val isTvShow: Boolean = false,

    @ColumnInfo(name = "is_seen")
    val isSeen: Boolean = false,

    @ColumnInfo(name = "is_owned")
    val isOwned: Boolean = false,

    @ColumnInfo(name = "is_favourite")
    val isFavourite: Boolean = false,

    @ColumnInfo(name = "format")
    val format: String = "Digital",

    @ColumnInfo(name = "age_rating")
    val ageRating: String = "NR",

    @ColumnInfo(name = "added_date")
    val addedDate: Long = 0L,

    @ColumnInfo(name = "loaned_date")
    val loanedDate: Long = 0L,

    @ColumnInfo(name = "plot")
    val plot: String = ""
)
