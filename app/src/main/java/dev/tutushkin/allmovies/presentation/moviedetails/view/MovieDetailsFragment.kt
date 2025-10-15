package dev.tutushkin.allmovies.presentation.moviedetails.view

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.annotation.VisibleForTesting
import androidx.core.os.bundleOf
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.google.android.material.snackbar.Snackbar
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.presentation.actors.view.ActorDetailsFragment
import dev.tutushkin.allmovies.databinding.FragmentMoviesDetailsBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.presentation.analytics.SharedLinkAnalyticsLogger
import dev.tutushkin.allmovies.presentation.extensions.toSlug
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsState
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsViewModel
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsViewModelFactory
import dev.tutushkin.allmovies.presentation.navigation.ARG_ACTOR_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SHARED
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SLUG
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.provideMoviesViewModelFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class MovieDetailsFragment : Fragment(R.layout.fragment_movies_details) {

    private var _binding: FragmentMoviesDetailsBinding? = null
    private val binding get() = _binding
    private var shareLink: String? = null
    private var shareTitle: String? = null
    private val args: MovieDetailsArgs by lazy { parseArgs(arguments) }

    @VisibleForTesting
    internal var moviesViewModelFactoryOverride: ViewModelProvider.Factory? = null

    private val moviesViewModel: MoviesViewModel by activityViewModels {
        moviesViewModelFactoryOverride ?: provideMoviesViewModelFactory()
    }

    @VisibleForTesting
    internal var viewModelFactoryOverride: ViewModelProvider.Factory? = null

    private val viewModel: MovieDetailsViewModel by viewModels {
        viewModelFactoryOverride ?: createMovieDetailsViewModelFactory()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        _binding = FragmentMoviesDetailsBinding.bind(view)

        viewModel.currentMovie.observe(viewLifecycleOwner, ::render)

        binding?.moviesDetailsBackText?.setOnClickListener {
            requireActivity().supportFragmentManager.popBackStack()
        }
        binding?.moviesDetailsBackImage?.setOnClickListener {
            requireActivity().supportFragmentManager.popBackStack()
        }

        binding?.moviesDetailsShareImage?.setOnClickListener {
            shareCurrentMovie()
        }

        binding?.moviesDetailsFavoriteImage?.setOnClickListener {
            viewModel.toggleFavorite()
        }
    }

    private fun render(state: MovieDetailsState) {
        when (state) {
            is MovieDetailsState.Result -> {
                hideLoading()
                renderResult(state.movie)
            }
            is MovieDetailsState.Error -> {
                hideLoading()
                val message = state.e.message ?: getString(R.string.library_update_failed_generic)
                binding?.root?.let {
                    Snackbar.make(
                        it,
                        message,
                        Snackbar.LENGTH_SHORT
                    ).show()
                }
                binding?.moviesDetailsShareImage?.isVisible = false
                binding?.moviesDetailsFavoriteImage?.isVisible = false
                shareLink = null
                shareTitle = null
            }
            is MovieDetailsState.Loading -> {
                showLoading()
                shareLink = null
                shareTitle = null
            }
        }
    }

    private fun renderResult(movie: MovieDetails) {
        binding?.apply {
            moviesDetailsAgeText.text = movie.minimumAge
            moviesDetailsTitleText.text = movie.title
            moviesDetailsGenresText.text = movie.genres
            moviesDetailsRating.rating = movie.ratings / 2
            moviesDetailsRatingsCountText.text =
                requireContext().getString(R.string.movie_details_reviews, movie.numberOfRatings)
            moviesDetailsDurationText.text =
                requireContext().getString(R.string.movies_list_duration, movie.runtime)
            moviesDetailsStorylineContentText.text = movie.overview
            Glide.with(requireContext())
                .load(movie.backdrop)
                .into(moviesDetailsPosterImage)
            movieDetailsActorsRecycler.layoutManager =
                LinearLayoutManager(requireContext(), RecyclerView.HORIZONTAL, false)
            movieDetailsActorsRecycler.adapter = ActorsAdapter(movie.actors) { actorId ->
                val args = bundleOf(ARG_ACTOR_ID to actorId)
                val fragment = ActorDetailsFragment().apply {
                    arguments = args
                }
                requireActivity().supportFragmentManager.beginTransaction()
                    .addToBackStack(null)
                    .replace(R.id.main_container, fragment)
                    .commit()
            }
            moviesDetailsShareImage.isVisible = true
            val favoriteIcon = if (movie.isFavorite) R.drawable.ic_like else R.drawable.ic_notlike
            moviesDetailsFavoriteImage.setImageResource(favoriteIcon)
            val description = if (movie.isFavorite) {
                getString(R.string.movie_details_favorite_remove)
            } else {
                getString(R.string.movie_details_favorite_add)
            }
            moviesDetailsFavoriteImage.contentDescription = description
            moviesDetailsFavoriteImage.isVisible = true
        }

        shareLink = buildShareLink(movie)
        shareTitle = movie.title
    }

    private fun createMovieDetailsViewModelFactory(): MovieDetailsViewModelFactory {
        val db = MoviesDb.getDatabase(requireActivity().application)
        val remoteDataSource = MoviesRemoteDataSourceImpl(NetworkModule.moviesApi)
        val localDataSource = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.actorDetailsDao(),
            db.configurationDao(),
            db.genresDao()
        )
        val repository = MoviesRepositoryImpl(remoteDataSource, localDataSource, Dispatchers.IO)
        val languagePreferences = LanguagePreferences(requireContext().applicationContext)

        return MovieDetailsViewModelFactory(
            repository,
            args.movieId,
            args.slug,
            args.openedFromSharedLink,
            SharedLinkAnalyticsLogger,
            languagePreferences.getSelectedLanguage(),
            moviesViewModel
        )
    }

    private fun showLoading() {
        binding?.apply {
            moviesDetailsLoadingOverlay.isVisible = true
            moviesDetailsShareImage.isVisible = false
            moviesDetailsFavoriteImage.isVisible = false
        }
    }

    private fun hideLoading() {
        binding?.moviesDetailsLoadingOverlay?.isVisible = false
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    private fun parseArgs(bundle: Bundle?): MovieDetailsArgs {
        val movieId = bundle?.getInt(ARG_MOVIE_ID, 0) ?: 0
        val slug = bundle?.getString(ARG_MOVIE_SLUG)
        val openedFromShare = bundle?.getBoolean(ARG_MOVIE_SHARED, false) ?: false
        return MovieDetailsArgs(movieId, slug, openedFromShare)
    }

    private fun buildShareLink(movie: MovieDetails): String {
        val slug = args.slug ?: movie.title.toSlug()
        return "app://collection/movie/${movie.id}/$slug"
    }

    private fun shareCurrentMovie() {
        val anchor = binding?.root ?: requireView()
        val link = shareLink ?: run {
            Snackbar.make(
                anchor,
                getString(R.string.movie_details_share_error),
                Snackbar.LENGTH_SHORT
            ).show()
            return
        }

        val title = shareTitle ?: run {
            Snackbar.make(
                anchor,
                getString(R.string.movie_details_share_error),
                Snackbar.LENGTH_SHORT
            ).show()
            return
        }
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_SUBJECT, title)
            putExtra(
                Intent.EXTRA_TEXT,
                getString(R.string.movie_details_share_message, title, link)
            )
        }

        startActivity(
            Intent.createChooser(
                shareIntent,
                getString(R.string.movie_details_share_chooser_title)
            )
        )
    }
}

private data class MovieDetailsArgs(
    val movieId: Int,
    val slug: String?,
    val openedFromSharedLink: Boolean
)
