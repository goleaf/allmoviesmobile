package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "actor_details")
data class ActorDetailsEntity(
    @PrimaryKey
    @ColumnInfo(name = "id")
    val id: Int,
    @ColumnInfo(name = "name")
    val name: String,
    @ColumnInfo(name = "biography")
    val biography: String,
    @ColumnInfo(name = "birthday")
    val birthday: String? = null,
    @ColumnInfo(name = "deathday")
    val deathday: String? = null,
    @ColumnInfo(name = "birthplace")
    val birthplace: String? = null,
    @ColumnInfo(name = "profileImage")
    val profileImage: String? = null,
    @ColumnInfo(name = "knownForDepartment")
    val knownForDepartment: String? = null,
    @ColumnInfo(name = "alsoKnownAs")
    val alsoKnownAs: List<String> = emptyList(),
    @ColumnInfo(name = "imdbId")
    val imdbId: String? = null,
    @ColumnInfo(name = "homepage")
    val homepage: String? = null,
    @ColumnInfo(name = "popularity")
    val popularity: Double = 0.0,
    @ColumnInfo(name = "knownFor")
    val knownFor: List<String> = emptyList(),
)
