package dev.tutushkin.allmovies.presentation.moviedetails.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.Category
import dev.tutushkin.allmovies.domain.movies.models.Format
import dev.tutushkin.allmovies.domain.movies.models.LoanRecord
import kotlinx.coroutines.launch

class MovieDetailsViewModel(
    private val moviesRepository: MoviesRepository,
    private val id: Int
) : ViewModel() {

    private val _currentMovie = MutableLiveData<MovieDetailsState>()
    val currentMovie: LiveData<MovieDetailsState> = _currentMovie

    private val _loanHistory = MutableLiveData<List<LoanRecord>>()
    val loanHistory: LiveData<List<LoanRecord>> = _loanHistory

    private val _availableFormats = MutableLiveData<List<Format>>()
    val availableFormats: LiveData<List<Format>> = _availableFormats

    private val _availableCategories = MutableLiveData<List<Category>>()
    val availableCategories: LiveData<List<Category>> = _availableCategories

    init {
        viewModelScope.launch {
            _currentMovie.value = handleMovieDetails()
            loadAuxiliaryData()
        }
    }

    private suspend fun handleMovieDetails(): MovieDetailsState {
        val movieDetails = moviesRepository.getMovieDetails(id, BuildConfig.API_KEY)

        return if (movieDetails.isSuccess)
            MovieDetailsState.Result(movieDetails.getOrThrow())
        else
            MovieDetailsState.Error(Exception("Error loading movie details from the server!"))
    }

    fun toggleFavorite(isFavorite: Boolean) {
        viewModelScope.launch {
            moviesRepository.updateFavorite(id, isFavorite)
            refreshMovie()
        }
    }

    fun toggleWatched(isWatched: Boolean) {
        viewModelScope.launch {
            moviesRepository.updateWatched(id, isWatched)
            refreshMovie()
        }
    }

    fun toggleWatchlist(isInWatchlist: Boolean) {
        viewModelScope.launch {
            moviesRepository.updateWatchlist(id, isInWatchlist)
            refreshMovie()
        }
    }

    fun updatePersonalNote(note: String?) {
        viewModelScope.launch {
            moviesRepository.updatePersonalNote(id, note)
            refreshMovie()
        }
    }

    fun assignFormat(formatId: Int?) {
        viewModelScope.launch {
            moviesRepository.assignFormat(id, formatId)
            refreshMovie()
        }
    }

    fun assignCategory(categoryId: Int?) {
        viewModelScope.launch {
            moviesRepository.assignCategory(id, categoryId)
            refreshMovie()
        }
    }

    fun recordLoan(borrowerName: String, loanDate: Long, returnDate: Long?) {
        viewModelScope.launch {
            moviesRepository.recordLoan(id, borrowerName, loanDate, returnDate)
            loadLoanHistory()
            refreshMovie()
        }
    }

    fun refreshLoanHistory() {
        viewModelScope.launch { loadLoanHistory() }
    }

    fun loadFormats() {
        viewModelScope.launch { loadFormatsInternal() }
    }

    fun loadCategories() {
        viewModelScope.launch { loadCategoriesInternal() }
    }

    private suspend fun refreshMovie() {
        _currentMovie.value = MovieDetailsState.Loading
        _currentMovie.value = handleMovieDetails()
    }

    private suspend fun loadAuxiliaryData() {
        loadLoanHistory()
        loadFormatsInternal()
        loadCategoriesInternal()
    }

    private suspend fun loadLoanHistory() {
        val result = moviesRepository.getLoanHistory(id)
        if (result.isSuccess) {
            _loanHistory.value = result.getOrDefault(emptyList())
        }
    }

    private suspend fun loadFormatsInternal() {
        val formats = moviesRepository.getFormats()
        if (formats.isSuccess) {
            _availableFormats.value = formats.getOrDefault(emptyList())
        }
    }

    private suspend fun loadCategoriesInternal() {
        val categories = moviesRepository.getCategories()
        if (categories.isSuccess) {
            _availableCategories.value = categories.getOrDefault(emptyList())
        }
    }

}