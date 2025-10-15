package dev.tutushkin.allmovies.data.movies.local

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "loan_records",
    foreignKeys = [
        ForeignKey(
            entity = MovieListEntity::class,
            parentColumns = ["id"],
            childColumns = ["movie_id"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["movie_id"])]
)
data class LoanRecordEntity(
    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "id")
    val id: Long = 0,
    @ColumnInfo(name = "movie_id")
    val movieId: Int,
    @ColumnInfo(name = "borrower_name")
    val borrowerName: String,
    @ColumnInfo(name = "loan_date")
    val loanDate: Long,
    @ColumnInfo(name = "return_date")
    val returnDate: Long?
)
