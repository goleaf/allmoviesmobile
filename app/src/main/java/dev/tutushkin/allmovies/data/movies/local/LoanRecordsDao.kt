package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update

@Dao
interface LoanRecordsDao {

    @Query("SELECT * FROM loan_records WHERE movie_id = :movieId ORDER BY loan_date DESC")
    suspend fun getByMovie(movieId: Int): List<LoanRecordEntity>

    @Insert
    suspend fun insert(loanRecordEntity: LoanRecordEntity): Long

    @Update
    suspend fun update(loanRecordEntity: LoanRecordEntity)

    @Query("DELETE FROM loan_records WHERE id = :id")
    suspend fun delete(id: Long)
}
