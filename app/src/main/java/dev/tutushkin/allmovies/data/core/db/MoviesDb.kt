package dev.tutushkin.allmovies.data.core.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import dev.tutushkin.allmovies.data.movies.local.*

@Database(
    entities = [
        MovieListEntity::class,
        MovieDetailsEntity::class,
        GenreEntity::class,
        ActorEntity::class,
        ConfigurationEntity::class
    ],
    version = 3,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class MoviesDb : RoomDatabase() {

    abstract fun moviesDao(): MoviesDao
    abstract fun movieDetails(): MovieDetailsDao
    abstract fun genresDao(): GenresDao
    abstract fun actorsDao(): ActorsDao
    abstract fun configurationDao(): ConfigurationDao

    companion object {

        @Volatile
        private var INSTANCE: MoviesDb? = null

        fun getDatabase(context: Context): MoviesDb {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    MoviesDb::class.java,
                    "Movies.db"
                )
//                    .allowMainThreadQueries()   // TODO Delete!!!
                    .addMigrations(MIGRATION_2_3)
                    .build()
                INSTANCE = instance
                instance
            }
        }

        private val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "ALTER TABLE movies ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0"
                )
                database.execSQL(
                    "ALTER TABLE movie_details ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0"
                )
            }
        }
    }

}