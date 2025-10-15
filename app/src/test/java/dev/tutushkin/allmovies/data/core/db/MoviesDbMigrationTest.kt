package dev.tutushkin.allmovies.data.core.db

import androidx.room.testing.MigrationTestHelper
import androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MoviesDbMigrationTest {

    @get:Rule
    val helper = MigrationTestHelper(
        InstrumentationRegistry.getInstrumentation(),
        MoviesDb::class.java.canonicalName,
        FrameworkSQLiteOpenHelperFactory()
    )

    @Test
    fun migrate4To5_addsCertificationColumns() {
        helper.createDatabase(TEST_DB, 4).apply {
            execSQL(
                """
                    INSERT INTO movies (
                        id, title, poster, ratings, numberOfRatings, minimumAge, year, genres, isFavorite
                    ) VALUES (
                        1, 'Movie', 'poster', 7.0, 100, '13+', '2021', 'Action', 0
                    )
                """.trimIndent()
            )
            execSQL(
                """
                    INSERT INTO movie_details (
                        id, title, overview, poster, backdrop, ratings, numberOfRatings, minimumAge, year,
                        runtime, genres, imdbId, trailerUrl, loanedTo, loanedSince, loanDue, loanStatus,
                        loanNotes, notes, actors, isActorsLoaded, isFavorite
                    ) VALUES (
                        1, 'Movie', 'Overview', 'poster', 'backdrop', 7.0, 100, '13+', '2021', 120, 'Action',
                        '', '', '', '', '', '', '', '', '', 0, 0
                    )
                """.trimIndent()
            )
            close()
        }

        helper.runMigrationsAndValidate(TEST_DB, 5, true, MoviesDb.MIGRATION_4_5)

        helper.openDatabase(TEST_DB, 5).use { db ->
            db.query("SELECT certificationCode, minimumAge FROM movies WHERE id = 1").use { cursor ->
                assertTrue(cursor.moveToFirst())
                assertEquals("", cursor.getString(0))
                assertEquals("13+", cursor.getString(1))
            }
            db.query("SELECT certificationCode, minimumAge FROM movie_details WHERE id = 1").use { cursor ->
                assertTrue(cursor.moveToFirst())
                assertEquals("", cursor.getString(0))
                assertEquals("13+", cursor.getString(1))
            }
        }
    }

    companion object {
        private const val TEST_DB = "migration-test"
    }
}
