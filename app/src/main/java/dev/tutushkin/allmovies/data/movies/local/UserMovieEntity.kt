package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "user_movies",
    foreignKeys = [
        ForeignKey(
            entity = MovieListEntity::class,
            parentColumns = ["id"],
            childColumns = ["movie_id"],
            onDelete = ForeignKey.CASCADE
        ),
        ForeignKey(
            entity = FormatEntity::class,
            parentColumns = ["id"],
            childColumns = ["format_id"],
            onDelete = ForeignKey.SET_NULL
        ),
        ForeignKey(
            entity = CategoryEntity::class,
            parentColumns = ["id"],
            childColumns = ["category_id"],
            onDelete = ForeignKey.SET_NULL
        )
    ],
    indices = [
        Index(value = ["movie_id"], unique = true),
        Index(value = ["format_id"]),
        Index(value = ["category_id"])
    ]
)
data class UserMovieEntity(
    @PrimaryKey
    @ColumnInfo(name = "movie_id")
    val movieId: Int,
    @ColumnInfo(name = "is_favorite")
    val isFavorite: Boolean = false,
    @ColumnInfo(name = "is_watched")
    val isWatched: Boolean = false,
    @ColumnInfo(name = "is_in_watchlist")
    val isInWatchlist: Boolean = false,
    @ColumnInfo(name = "format_id")
    val formatId: Int? = null,
    @ColumnInfo(name = "category_id")
    val categoryId: Int? = null
)
