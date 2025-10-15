package dev.tutushkin.allmovies.presentation.movieform.view

import android.os.Bundle
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.databinding.FragmentMovieEditBinding
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel
import dev.tutushkin.allmovies.utils.YouTubeTrailerSearcher
import kotlinx.coroutines.Dispatchers

class MovieEditFragment : Fragment(R.layout.fragment_movie_edit) {

    private var _binding: FragmentMovieEditBinding? = null
    private val binding get() = _binding!!

    private val draftId: Long? by lazy {
        if (arguments?.containsKey(ARG_DRAFT_ID) == true) {
            arguments?.getLong(ARG_DRAFT_ID)
        } else {
            null
        }
    }

    private lateinit var screen: MovieFormScreen

    private val viewModel: MovieFormViewModel by viewModels {
        val application = requireActivity().application
        val db = MoviesDb.getDatabase(application)
        val remote = MoviesRemoteDataSourceImpl(NetworkModule.moviesApi)
        val local = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.configurationDao(),
            db.genresDao(),
            db.draftMoviesDao()
        )
        val repository = MoviesRepositoryImpl(remote, local, Dispatchers.Default)
        val youtubeSearcher = YouTubeTrailerSearcher(NetworkModule.httpClient, BuildConfig.YOUTUBE_API_KEY)
        MovieFormViewModel.Factory(application, repository, youtubeSearcher, draftId)
    }

    private val pickCoverLauncher =
        registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
            uri?.let(viewModel::onCoverSelected)
        }

    override fun onViewCreated(view: android.view.View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentMovieEditBinding.bind(view)

        screen = MovieFormScreen(
            fragment = this,
            binding = binding.movieEditFormContainer,
            viewModel = viewModel
        ) {
            pickCoverLauncher.launch("image/*")
        }
        screen.initialize()
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    companion object {
        private const val ARG_DRAFT_ID = "arg_draft_id"

        fun newInstance(draftId: Long): MovieEditFragment = MovieEditFragment().apply {
            arguments = bundleOf(ARG_DRAFT_ID to draftId)
        }
    }
}
