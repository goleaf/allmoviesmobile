package dev.tutushkin.allmovies.presentation.moviedetails.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.presentation.analytics.SharedLinkAnalytics

class MovieDetailsViewModelFactory(
    private val repository: MoviesRepository,
    private val id: Int,
    private val slug: String?,
    private val openedFromSharedLink: Boolean,
    private val analytics: SharedLinkAnalytics
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MovieDetailsViewModel::class.java)) {
            return MovieDetailsViewModel(repository, id, slug, openedFromSharedLink, analytics) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}