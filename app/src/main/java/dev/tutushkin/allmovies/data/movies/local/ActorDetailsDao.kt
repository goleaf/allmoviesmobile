package dev.tutushkin.allmovies.data.movies.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface ActorDetailsDao {

    @Query("SELECT * FROM actor_details WHERE id = :actorId LIMIT 1")
    fun getActorDetails(actorId: Int): ActorDetailsEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(actorDetails: ActorDetailsEntity)

    @Query("DELETE FROM actor_details")
    fun clear()
}
