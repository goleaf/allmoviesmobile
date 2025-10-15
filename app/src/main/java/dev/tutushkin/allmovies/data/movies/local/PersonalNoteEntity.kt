package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "personal_notes",
    foreignKeys = [
        ForeignKey(
            entity = MovieListEntity::class,
            parentColumns = ["id"],
            childColumns = ["movie_id"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["movie_id"], unique = true)]
)
data class PersonalNoteEntity(
    @PrimaryKey
    @ColumnInfo(name = "movie_id")
    val movieId: Int,
    @ColumnInfo(name = "note")
    val note: String,
    @ColumnInfo(name = "updated_at")
    val updatedAt: Long
)
