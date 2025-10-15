package dev.tutushkin.allmovies.presentation.movies.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.data.core.network.NetworkModule.allGenres
import dev.tutushkin.allmovies.data.core.network.NetworkModule.configApi
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import dev.tutushkin.allmovies.domain.auth.AuthState
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class MoviesViewModel(
    private val moviesRepository: MoviesRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _movies = MutableLiveData<MoviesState>()
    val movies: LiveData<MoviesState> = _movies

    private val _collectionState = MutableLiveData(CollectionAccessState.Hidden)
    val collectionState: LiveData<CollectionAccessState> = _collectionState

    private val _collectionPermissions = MutableLiveData(CollectionPermissions())
    val collectionPermissions: LiveData<CollectionPermissions> = _collectionPermissions

    private var moviesLoaded = false

    init {
        viewModelScope.launch {
            authRepository.observeAuthState().collect { state ->
                when (state) {
                    AuthState.Unauthenticated, AuthState.Guest -> {
                        _collectionState.postValue(CollectionAccessState.Hidden)
                        _collectionPermissions.postValue(CollectionPermissions())
                        moviesLoaded = false
                    }
                    is AuthState.Authenticated -> {
                        val account = state.account
                        if (account.canViewCollection()) {
                            _collectionState.postValue(CollectionAccessState.Visible)
                            _collectionPermissions.postValue(
                                CollectionPermissions(
                                    canAdd = account.canModifyCollection(),
                                    canEdit = account.canModifyCollection(),
                                    canDelete = account.canModifyCollection(),
                                    canManageUsers = account.canManageUsers()
                                )
                            )
                            ensureMoviesLoaded()
                        } else {
                            _collectionState.postValue(CollectionAccessState.Hidden)
                            _collectionPermissions.postValue(CollectionPermissions())
                        }
                    }
                    is AuthState.SessionExpired -> {
                        _collectionState.postValue(CollectionAccessState.Hidden)
                        _collectionPermissions.postValue(CollectionPermissions())
                        moviesLoaded = false
                    }
                }
            }
        }
    }

    private suspend fun ensureMoviesLoaded() {
        if (moviesLoaded) return
        moviesRepository.clearAll()

        handleLoadApiConfiguration()
        handleGenres()

        _movies.postValue(handleMoviesNowPlaying())
        moviesLoaded = true
    }

    private suspend fun handleLoadApiConfiguration() {
        val conf = moviesRepository.getConfiguration(BuildConfig.API_KEY)

        if (conf.isSuccess) {
            configApi = conf.getOrThrow()
        } else {
            println(conf.exceptionOrNull())
        }
    }

    private suspend fun handleGenres() {
        val genres = moviesRepository.getGenres(BuildConfig.API_KEY)

        if (genres.isSuccess) {
            allGenres = genres.getOrThrow()
        } else {
            println(genres.exceptionOrNull())
        }
    }

    private suspend fun handleMoviesNowPlaying(): MoviesState {
        val moviesResult = moviesRepository.getNowPlaying(BuildConfig.API_KEY)

        return if (moviesResult.isSuccess)
            MoviesState.Result(moviesResult.getOrThrow())
        else
            MoviesState.Error(IllegalArgumentException("Error loading movies from the server!"))
    }

}

enum class CollectionAccessState {
    Visible,
    Hidden
}

data class CollectionPermissions(
    val canAdd: Boolean = false,
    val canEdit: Boolean = false,
    val canDelete: Boolean = false,
    val canManageUsers: Boolean = false
)