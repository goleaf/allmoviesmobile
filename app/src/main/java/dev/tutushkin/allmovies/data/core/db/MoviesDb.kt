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
        ConfigurationEntity::class,
        ActorDetailsEntity::class,
    ],
    version = 5,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class MoviesDb : RoomDatabase() {

    abstract fun moviesDao(): MoviesDao
    abstract fun movieDetails(): MovieDetailsDao
    abstract fun genresDao(): GenresDao
    abstract fun actorsDao(): ActorsDao
    abstract fun configurationDao(): ConfigurationDao
    abstract fun actorDetailsDao(): ActorDetailsDao

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
                    // Room requires database operations to be performed off the main thread.
                    .addMigrations(MIGRATION_2_3, MIGRATION_3_4, MIGRATION_4_5)
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

        private val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    """
                        CREATE TABLE IF NOT EXISTS actor_details (
                            id INTEGER NOT NULL,
                            name TEXT NOT NULL,
                            biography TEXT NOT NULL,
                            birthday TEXT,
                            deathday TEXT,
                            birthplace TEXT,
                            profileImage TEXT,
                            knownForDepartment TEXT,
                            alsoKnownAs TEXT NOT NULL DEFAULT '',
                            imdbId TEXT,
                            homepage TEXT,
                            popularity REAL NOT NULL DEFAULT 0.0,
                            knownFor TEXT NOT NULL DEFAULT '',
                            PRIMARY KEY(id)
                        )
                    """.trimIndent()
                )
            }
        }

        internal val MIGRATION_4_5 = object : Migration(4, 5) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "ALTER TABLE movies ADD COLUMN certificationCode TEXT NOT NULL DEFAULT ''"
                )
                database.execSQL(
                    "ALTER TABLE movie_details ADD COLUMN certificationCode TEXT NOT NULL DEFAULT ''"
                )
            }
        }
    }

}