package dev.tutushkin.allmovies.presentation.favorites.viewmodel

import androidx.fragment.app.Fragment
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule.moviesApi
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifierProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

@OptIn(ExperimentalSerializationApi::class)
fun Fragment.provideFavoritesViewModelFactory(): FavoritesViewModelFactory {
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
    val repository = MoviesRepositoryImpl(remoteDataSource, localDataSource, Dispatchers.Default)
    val favoritesNotifier = FavoritesUpdateNotifierProvider.notifier
    return FavoritesViewModelFactory(repository, favoritesNotifier)
}
