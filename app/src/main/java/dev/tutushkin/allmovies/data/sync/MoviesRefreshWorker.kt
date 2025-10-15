package dev.tutushkin.allmovies.data.sync

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.ConfigurationDataStore
import dev.tutushkin.allmovies.data.movies.createImageSizeSelector
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.local.configurationPreferencesDataStore
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

@OptIn(ExperimentalSerializationApi::class)
class MoviesRefreshWorker(
    context: Context,
    workerParameters: WorkerParameters
) : CoroutineWorker(context, workerParameters) {

    private val notificationHelper = MoviesRefreshNotificationHelper(applicationContext)

    override suspend fun doWork(): Result {
        val db = MoviesDb.getDatabase(applicationContext)
        val localDataSource = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.actorDetailsDao(),
            db.configurationDao(),
            db.genresDao()
        )
        val remoteDataSource = MoviesRemoteDataSourceImpl(NetworkModule.moviesApi)
        val configurationDataStore = ConfigurationDataStore(
            applicationContext.configurationPreferencesDataStore
        )
        val imageSizeSelector = applicationContext.createImageSizeSelector()
        val repository = MoviesRepositoryImpl(
            remoteDataSource,
            localDataSource,
            configurationDataStore,
            Dispatchers.IO,
            imageSizeSelector
        )
        val languageCode = LanguagePreferences(applicationContext).getSelectedLanguage()

        setForegroundAsync(
            notificationHelper.createForegroundInfo(
                0,
                0,
                applicationContext.getString(R.string.library_update_preparing)
            )
        )

        val result = repository.refreshLibrary(languageCode) { current, total, title ->
            val progressData = workDataOf(
                PROGRESS_CURRENT to current,
                PROGRESS_TOTAL to total,
                PROGRESS_TITLE to title
            )
            setProgressAsync(progressData)
            setForegroundAsync(notificationHelper.createForegroundInfo(current, total, title))
        }

        return if (result.isSuccess) {
            notificationHelper.showCompleted()
            Result.success()
        } else {
            val message = result.exceptionOrNull()?.localizedMessage
                ?: applicationContext.getString(R.string.library_update_failed_generic)
            setProgress(workDataOf(KEY_ERROR_MESSAGE to message))
            notificationHelper.showFailed(message)
            Result.failure(workDataOf(KEY_ERROR_MESSAGE to message))
        }
    }

    companion object {
        const val WORK_NAME = "movies-refresh-work"
        const val WORK_TAG = "movies-refresh-tag"
        const val PROGRESS_CURRENT = "progress_current"
        const val PROGRESS_TOTAL = "progress_total"
        const val PROGRESS_TITLE = "progress_title"
        const val KEY_ERROR_MESSAGE = "error_message"
    }
}

private class MoviesRefreshNotificationHelper(private val context: Context) {

    private val notificationManager: NotificationManagerCompat = NotificationManagerCompat.from(context)

    fun createForegroundInfo(current: Int, total: Int, title: String): ForegroundInfo {
        createChannel()

        val progressPercent = if (total <= 0) 0 else ((current.coerceAtMost(total)).toFloat() / total * 100).toInt()
        val contentText = if (total <= 0) {
            context.getString(R.string.library_update_preparing)
        } else {
            context.getString(
                R.string.library_update_progress,
                progressPercent,
                title.ifBlank { context.getString(R.string.library_update_unknown_title) }
            )
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.library_update_title))
            .setContentText(contentText)
            .setOngoing(true)
            .setProgress(100, progressPercent, total <= 0)
            .setOnlyAlertOnce(true)
            .build()

        return ForegroundInfo(NOTIFICATION_ID, notification)
    }

    fun showCompleted() {
        createChannel()
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.library_update_title))
            .setContentText(context.getString(R.string.library_update_success))
            .setAutoCancel(true)
            .build()
        notificationManager.notify(NOTIFICATION_COMPLETE_ID, notification)
    }

    fun showFailed(message: String) {
        createChannel()
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.library_update_title))
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setAutoCancel(true)
            .build()
        notificationManager.notify(NOTIFICATION_COMPLETE_ID, notification)
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (manager.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    context.getString(R.string.library_update_channel_name),
                    NotificationManager.IMPORTANCE_LOW
                )
                manager.createNotificationChannel(channel)
            }
        }
    }

    companion object {
        private const val CHANNEL_ID = "movies-refresh-channel"
        private const val NOTIFICATION_ID = 2001
        private const val NOTIFICATION_COMPLETE_ID = 2002
    }
}
