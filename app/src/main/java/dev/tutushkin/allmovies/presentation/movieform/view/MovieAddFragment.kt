package dev.tutushkin.allmovies.presentation.movieform.view

import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.databinding.FragmentMovieAddBinding
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel
import dev.tutushkin.allmovies.utils.YouTubeTrailerSearcher
import kotlinx.coroutines.Dispatchers

class MovieAddFragment : Fragment(R.layout.fragment_movie_add) {

    private var _binding: FragmentMovieAddBinding? = null
    private val binding get() = _binding!!

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
        MovieFormViewModel.Factory(application, repository, youtubeSearcher, null)
    }

    private val pickCoverLauncher =
        registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
            uri?.let(viewModel::onCoverSelected)
        }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentMovieAddBinding.bind(view)
        screen = MovieFormScreen(
            fragment = this,
            binding = binding.movieFormContainer,
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
}
