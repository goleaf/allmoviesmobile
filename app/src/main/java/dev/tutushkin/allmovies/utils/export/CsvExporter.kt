package dev.tutushkin.allmovies.utils.export

import android.content.Context
import android.net.Uri
import android.os.Environment
import androidx.core.content.FileProvider
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.MovieListEntity
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.text.Charsets

class CsvExporter(private val context: Context) {

    suspend fun exportLibrary(): ExportResult = withContext(Dispatchers.IO) {
        val db = MoviesDb.getDatabase(context)
        val localDataSource = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.actorDetailsDao(),
            db.configurationDao(),
            db.genresDao()
        )

        val movies = localDataSource.getNowPlaying()
        val detailsById = localDataSource.getAllMovieDetails().associateBy { it.id }

        val csvBuilder = StringBuilder()
        val headers = context.resources.getStringArray(R.array.export_csv_headers)
        val yesLabel = context.getString(R.string.export_csv_yes)
        val noLabel = context.getString(R.string.export_csv_no)
        csvBuilder.appendLine(headers.joinToString(separator = CSV_SEPARATOR))
        movies.forEachIndexed { index, movie ->
            val details = detailsById[movie.id]
            val rowValues = buildRow(index + 1, movie, details, yesLabel, noLabel)
            csvBuilder.appendLine(rowValues.joinToString(separator = CSV_SEPARATOR) { escape(it) })
        }

        val exportDir = context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS) ?: context.filesDir
        if (!exportDir.exists()) {
            exportDir.mkdirs()
        }
        val timestamp = SimpleDateFormat(FILE_TIMESTAMP_PATTERN, Locale.getDefault()).format(Date())
        val exportFile = File(exportDir, "allmovies-$timestamp.csv")
        FileOutputStream(exportFile).use { output ->
            output.write(csvBuilder.toString().toByteArray(Charsets.UTF_8))
        }

        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            exportFile
        )

        ExportResult(uri, exportFile, MIME_TYPE_CSV)
    }

    private fun buildRow(
        position: Int,
        movie: MovieListEntity,
        details: MovieDetailsEntity?,
        yesLabel: String,
        noLabel: String
    ): List<String> {
        val runtime = details?.runtime?.takeIf { it > 0 }?.toString().orEmpty()
        val rating = if (movie.ratings > 0f) {
            String.format(Locale.getDefault(), "%.1f", movie.ratings)
        } else {
            ""
        }

        val loanedTo = details?.loanedTo.orEmpty()
        val loaned = if (loanedTo.isNotBlank()) yesLabel else noLabel

        return listOf(
            position.toString(),
            details?.imdbId.orEmpty(),
            movie.title,
            movie.year,
            runtime,
            rating,
            movie.minimumAge,
            movie.genres,
            loaned,
            loanedTo,
            details?.loanedSince.orEmpty(),
            details?.loanDue.orEmpty(),
            details?.loanStatus.orEmpty(),
            details?.loanNotes.orEmpty(),
            details?.notes.orEmpty(),
            details?.trailerUrl.orEmpty()
        )
    }

    private fun escape(value: String): String {
        val sanitized = value.replace("\r", " ").replace("\n", " ")
        return "\"" + sanitized.replace("\"", "\"\"") + "\""
    }

    companion object {
        private const val CSV_SEPARATOR = ","
        private const val FILE_TIMESTAMP_PATTERN = "yyyyMMdd-HHmmss"
        private const val MIME_TYPE_CSV = "text/csv"
    }
}

data class ExportResult(
    val uri: Uri,
    val file: File,
    val mimeType: String
)
