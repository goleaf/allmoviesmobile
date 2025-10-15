package dev.tutushkin.allmovies.data.core.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import dev.tutushkin.allmovies.data.movies.local.ActorEntity
import dev.tutushkin.allmovies.data.movies.local.ActorsDao
import dev.tutushkin.allmovies.data.movies.local.CategoriesDao
import dev.tutushkin.allmovies.data.movies.local.CategoryEntity
import dev.tutushkin.allmovies.data.movies.local.ConfigurationDao
import dev.tutushkin.allmovies.data.movies.local.ConfigurationEntity
import dev.tutushkin.allmovies.data.movies.local.FormatEntity
import dev.tutushkin.allmovies.data.movies.local.FormatsDao
import dev.tutushkin.allmovies.data.movies.local.GenreEntity
import dev.tutushkin.allmovies.data.movies.local.GenresDao
import dev.tutushkin.allmovies.data.movies.local.LoanRecordEntity
import dev.tutushkin.allmovies.data.movies.local.LoanRecordsDao
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsDao
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.MovieListEntity
import dev.tutushkin.allmovies.data.movies.local.MoviesDao
import dev.tutushkin.allmovies.data.movies.local.PersonalNoteEntity
import dev.tutushkin.allmovies.data.movies.local.PersonalNotesDao
import dev.tutushkin.allmovies.data.movies.local.UserMovieEntity
import dev.tutushkin.allmovies.data.movies.local.UserMoviesDao

@Database(
    entities = [
        MovieListEntity::class,
        MovieDetailsEntity::class,
        GenreEntity::class,
        ActorEntity::class,
        ConfigurationEntity::class,
        UserMovieEntity::class,
        PersonalNoteEntity::class,
        FormatEntity::class,
        CategoryEntity::class,
        LoanRecordEntity::class
    ],
    version = 2,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class MoviesDb : RoomDatabase() {

    abstract fun moviesDao(): MoviesDao
    abstract fun movieDetails(): MovieDetailsDao
    abstract fun genresDao(): GenresDao
    abstract fun actorsDao(): ActorsDao
    abstract fun configurationDao(): ConfigurationDao
    abstract fun userMoviesDao(): UserMoviesDao
    abstract fun personalNotesDao(): PersonalNotesDao
    abstract fun formatsDao(): FormatsDao
    abstract fun categoriesDao(): CategoriesDao
    abstract fun loanRecordsDao(): LoanRecordsDao

    companion object {

        @Volatile
        private var INSTANCE: MoviesDb? = null

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "CREATE TABLE IF NOT EXISTS `formats` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `name` TEXT NOT NULL)"
                )
                database.execSQL(
                    "CREATE TABLE IF NOT EXISTS `categories` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `name` TEXT NOT NULL)"
                )
                database.execSQL(
                    "CREATE TABLE IF NOT EXISTS `user_movies` (`movie_id` INTEGER NOT NULL, `is_favorite` INTEGER NOT NULL, `is_watched` INTEGER NOT NULL, `is_in_watchlist` INTEGER NOT NULL, `format_id` INTEGER, `category_id` INTEGER, PRIMARY KEY(`movie_id`), FOREIGN KEY(`movie_id`) REFERENCES `movies`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY(`format_id`) REFERENCES `formats`(`id`) ON UPDATE NO ACTION ON DELETE SET NULL, FOREIGN KEY(`category_id`) REFERENCES `categories`(`id`) ON UPDATE NO ACTION ON DELETE SET NULL)"
                )
                database.execSQL(
                    "CREATE UNIQUE INDEX IF NOT EXISTS `index_user_movies_movie_id` ON `user_movies` (`movie_id`)"
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS `index_user_movies_format_id` ON `user_movies` (`format_id`)"
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS `index_user_movies_category_id` ON `user_movies` (`category_id`)"
                )
                database.execSQL(
                    "CREATE TABLE IF NOT EXISTS `personal_notes` (`movie_id` INTEGER NOT NULL, `note` TEXT NOT NULL, `updated_at` INTEGER NOT NULL, PRIMARY KEY(`movie_id`), FOREIGN KEY(`movie_id`) REFERENCES `movies`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE)"
                )
                database.execSQL(
                    "CREATE UNIQUE INDEX IF NOT EXISTS `index_personal_notes_movie_id` ON `personal_notes` (`movie_id`)"
                )
                database.execSQL(
                    "CREATE TABLE IF NOT EXISTS `loan_records` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `movie_id` INTEGER NOT NULL, `borrower_name` TEXT NOT NULL, `loan_date` INTEGER NOT NULL, `return_date` INTEGER, FOREIGN KEY(`movie_id`) REFERENCES `movies`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE)"
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS `index_loan_records_movie_id` ON `loan_records` (`movie_id`)"
                )
            }
        }

        fun getDatabase(context: Context): MoviesDb {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    MoviesDb::class.java,
                    "Movies.db"
                )
//                    .allowMainThreadQueries()   // TODO Delete!!!
                    .addMigrations(MIGRATION_1_2)
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }

}