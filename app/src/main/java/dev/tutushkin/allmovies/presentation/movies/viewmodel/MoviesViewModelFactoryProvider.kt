package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.fragment.app.Fragment
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule.moviesApi
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.createImageSizeSelector
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.local.ConfigurationDataStore
import dev.tutushkin.allmovies.data.movies.local.configurationPreferencesDataStore
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifierProvider
import dev.tutushkin.allmovies.utils.logging.LoggerProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

@OptIn(ExperimentalSerializationApi::class)
fun Fragment.provideMoviesViewModelFactory(): MoviesViewModelFactory {
    val application = requireActivity().application
    val db = MoviesDb.getDatabase(application)
    val localDataSource = MoviesLocalDataSourceImpl(
        db.moviesDao(),
        db.movieDetails(),
        db.actorsDao(),
        db.actorDetailsDao(),
        db.configurationDao(),
        db.genresDao()
    )
    val remoteDataSource = MoviesRemoteDataSourceImpl(moviesApi)
    val configurationDataStore = ConfigurationDataStore(
        requireContext().applicationContext.configurationPreferencesDataStore
    )
    val imageSizeSelector = application.createImageSizeSelector()
    val repository = MoviesRepositoryImpl(
        remoteDataSource,
        localDataSource,
        configurationDataStore,
        Dispatchers.IO,
        imageSizeSelector
    )
    val languagePreferences = LanguagePreferences(requireContext().applicationContext)
    val favoritesNotifier = FavoritesUpdateNotifierProvider.notifier
    return MoviesViewModelFactory(
        repository,
        languagePreferences,
        favoritesNotifier,
        LoggerProvider.logger
    )
}
