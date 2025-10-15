package dev.tutushkin.allmovies.presentation.imdb.view

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.bumptech.glide.Glide
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.imdb.remote.ImdbRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.databinding.FragmentImdbImportBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.presentation.imdb.viewmodel.ImdbImportState
import dev.tutushkin.allmovies.presentation.imdb.viewmodel.ImdbImportViewModel
import dev.tutushkin.allmovies.presentation.imdb.viewmodel.ImdbImportViewModelFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class ImdbImportFragment : Fragment(R.layout.fragment_imdb_import) {

    private var _binding: FragmentImdbImportBinding? = null
    private val binding get() = _binding!!

    private lateinit var viewModel: ImdbImportViewModel
    private var imdbId: String? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        imdbId = arguments?.getString(IMDB_ID_KEY)

        val db = MoviesDb.getDatabase(requireActivity().application)
        val remoteDataSource = MoviesRemoteDataSourceImpl(NetworkModule.moviesApi)
        val imdbRemoteDataSource = ImdbRemoteDataSourceImpl(NetworkModule.imdbApi)
        val localDataSource = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.configurationDao(),
            db.genresDao()
        )
        val repository = MoviesRepositoryImpl(
            remoteDataSource,
            localDataSource,
            imdbRemoteDataSource,
            Dispatchers.Default
        )
        val viewModelFactory = ImdbImportViewModelFactory(repository, BuildConfig.IMDB_API_KEY)
        val imdbImportViewModel: ImdbImportViewModel by viewModels { viewModelFactory }
        viewModel = imdbImportViewModel

        _binding = FragmentImdbImportBinding.bind(view)

        binding.imdbImportAction.isEnabled = imdbId != null

        binding.imdbImportAction.setOnClickListener {
            imdbId?.let { viewModel.import(it) }
        }

        viewModel.state.observe(viewLifecycleOwner, ::renderState)

        if (savedInstanceState == null) {
            imdbId?.let { viewModel.load(it) }
        } else {
            viewModel.restoreLastState()
        }
    }

    private fun renderState(state: ImdbImportState) {
        when (state) {
            is ImdbImportState.Loading -> {
                showLoading(true)
            }
            is ImdbImportState.Ready -> {
                showLoading(false)
                renderMovie(state.movie)
                binding.imdbImportAction.isEnabled = true
            }
            is ImdbImportState.Imported -> {
                showLoading(false)
                renderMovie(state.movie)
                binding.imdbImportAction.isEnabled = false
                Toast.makeText(requireContext(), R.string.imdb_import_success, Toast.LENGTH_SHORT)
                    .show()
            }
            is ImdbImportState.Error -> {
                showLoading(false)
                binding.imdbImportAction.isEnabled = true
                Toast.makeText(requireContext(), state.throwable.message ?: getString(R.string.imdb_import_failure), Toast.LENGTH_SHORT)
                    .show()
                viewModel.restoreLastState()
            }
        }
    }

    private fun renderMovie(movie: MovieDetails) {
        binding.imdbImportTitle.text = movie.title
        binding.imdbImportOverview.text = movie.overview
        binding.imdbImportRuntime.text = getString(R.string.imdb_import_runtime_format, movie.runtime)
        binding.imdbImportYear.text = getString(R.string.imdb_import_year_format, movie.year)
        binding.imdbImportRating.text = getString(R.string.imdb_import_rating_format, movie.minimumAge)
        binding.imdbImportGenres.text = getString(R.string.imdb_import_genres_format, movie.genres)
        binding.imdbImportDirectors.text = formatList(R.string.imdb_import_directors_label, movie.directors)
        binding.imdbImportWriters.text = formatList(R.string.imdb_import_writers_label, movie.writers)
        binding.imdbImportLanguages.text = formatList(R.string.imdb_import_languages_label, movie.languages)
        binding.imdbImportSubtitles.text = formatList(R.string.imdb_import_subtitles_label, movie.subtitles)
        binding.imdbImportAudio.text = formatList(R.string.imdb_import_audio_label, movie.audioTracks)
        binding.imdbImportVideo.text = formatList(R.string.imdb_import_video_label, movie.videoFormats)
        binding.imdbImportTrailers.text = formatList(R.string.imdb_import_trailers_label, movie.trailerUrls)

        Glide.with(requireContext())
            .load(movie.backdrop)
            .into(binding.imdbImportPoster)
    }

    private fun formatList(labelRes: Int, values: List<String>): String {
        val label = getString(labelRes)
        val formattedValues = if (values.isEmpty()) {
            "-"
        } else {
            values.joinToString(separator = ", ")
        }
        return "$label: $formattedValues"
    }

    private fun showLoading(isLoading: Boolean) {
        binding.imdbImportProgress.visibility = if (isLoading) View.VISIBLE else View.GONE
        binding.imdbImportAction.isEnabled = !isLoading
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
