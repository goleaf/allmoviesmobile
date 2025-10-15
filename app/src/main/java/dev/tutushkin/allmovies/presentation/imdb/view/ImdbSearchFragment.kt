package dev.tutushkin.allmovies.presentation.imdb.view

import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.imdb.remote.ImdbRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.databinding.FragmentImdbSearchBinding
import dev.tutushkin.allmovies.presentation.imdb.view.adapter.ImdbSearchAdapter
import dev.tutushkin.allmovies.presentation.imdb.view.adapter.ImdbSearchClickListener
import dev.tutushkin.allmovies.presentation.imdb.viewmodel.ImdbSearchState
import dev.tutushkin.allmovies.presentation.imdb.viewmodel.ImdbSearchViewModel
import dev.tutushkin.allmovies.presentation.imdb.viewmodel.ImdbSearchViewModelFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

const val IMDB_ID_KEY = "imdb_id"

@ExperimentalSerializationApi
class ImdbSearchFragment : Fragment(R.layout.fragment_imdb_search) {

    private var _binding: FragmentImdbSearchBinding? = null
    private val binding get() = _binding!!

    private lateinit var viewModel: ImdbSearchViewModel
    private lateinit var adapter: ImdbSearchAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

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
        val viewModelFactory = ImdbSearchViewModelFactory(repository, BuildConfig.IMDB_API_KEY)
        val imdbSearchViewModel: ImdbSearchViewModel by viewModels { viewModelFactory }
        viewModel = imdbSearchViewModel

        _binding = FragmentImdbSearchBinding.bind(view)
        adapter = ImdbSearchAdapter(object : ImdbSearchClickListener {
            override fun onImdbSearchResultClick(result: dev.tutushkin.allmovies.domain.movies.models.ImdbSearchResult) {
                navigateToImport(result.imdbId)
            }
        })

        binding.imdbSearchResults.layoutManager = LinearLayoutManager(requireContext())
        binding.imdbSearchResults.adapter = adapter

        binding.imdbSearchButton.setOnClickListener {
            triggerSearch()
        }

        binding.imdbSearchInput.setOnEditorActionListener { _, actionId, event ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH || event?.keyCode == KeyEvent.KEYCODE_ENTER) {
                triggerSearch()
                true
            } else {
                false
            }
        }

        viewModel.state.observe(viewLifecycleOwner, ::renderState)
    }

    private fun triggerSearch() {
        val query = binding.imdbSearchInput.text?.toString().orEmpty()
        viewModel.search(query)
    }

    private fun renderState(state: ImdbSearchState) {
        when (state) {
            is ImdbSearchState.Idle -> {
                binding.imdbSearchProgress.visibility = View.GONE
                binding.imdbSearchEmpty.visibility = View.VISIBLE
                binding.imdbSearchEmpty.setText(R.string.imdb_search_empty)
                adapter.submitList(emptyList())
            }
            is ImdbSearchState.Loading -> {
                binding.imdbSearchProgress.visibility = View.VISIBLE
                binding.imdbSearchEmpty.visibility = View.GONE
            }
            is ImdbSearchState.Results -> {
                binding.imdbSearchProgress.visibility = View.GONE
                adapter.submitList(state.items)
                if (state.items.isEmpty()) {
                    binding.imdbSearchEmpty.visibility = View.VISIBLE
                    binding.imdbSearchEmpty.setText(R.string.imdb_search_no_results)
                } else {
                    binding.imdbSearchEmpty.visibility = View.GONE
                }
            }
            is ImdbSearchState.Error -> {
                binding.imdbSearchProgress.visibility = View.GONE
                if (adapter.currentList.isEmpty()) {
                    binding.imdbSearchEmpty.visibility = View.VISIBLE
                    binding.imdbSearchEmpty.setText(R.string.imdb_search_error)
                }
                Toast.makeText(requireContext(), state.throwable.message, Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun navigateToImport(imdbId: String) {
        val fragment = ImdbImportFragment().apply {
            arguments = Bundle().apply { putString(IMDB_ID_KEY, imdbId) }
        }
        requireActivity().supportFragmentManager.beginTransaction()
            .addToBackStack(null)
            .replace(R.id.main_container, fragment)
            .commit()
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
