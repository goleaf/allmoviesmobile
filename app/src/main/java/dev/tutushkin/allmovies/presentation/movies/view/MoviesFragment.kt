package dev.tutushkin.allmovies.presentation.movies.view

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import android.content.res.Configuration
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule.moviesApi
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.preferences.SearchPreferencesDataSource
import dev.tutushkin.allmovies.databinding.FragmentMoviesListBinding
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.domain.movies.models.LayoutMode
import dev.tutushkin.allmovies.presentation.movies.viewmodel.SearchUiState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.SearchViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.SearchViewModelFactory
import kotlinx.coroutines.Job
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import kotlinx.serialization.ExperimentalSerializationApi
import androidx.core.widget.doOnTextChanged

const val MOVIES_KEY = "MOVIES"

@ExperimentalSerializationApi
class MoviesFragment : Fragment(R.layout.fragment_movies_list) {

    private var _binding: FragmentMoviesListBinding? = null
    private val binding get() = _binding!!

    private lateinit var adapter: MoviesAdapter
    private lateinit var viewModel: SearchViewModel
    private var stateCollector: Job? = null
    private var latestState: SearchUiState = SearchUiState()
    private var isUpdatingQuery = false
    private var isUpdatingLayout = false
    private var lastErrorMessage: String? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

// TODO Column alignment RecyclerView
//        val displayMetrics = DisplayMetrics()
//            ...

        val db = MoviesDb.getDatabase(requireActivity().application)
        val remoteDataSource = MoviesRemoteDataSourceImpl(moviesApi)
        val localDataSource = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.configurationDao(),
            db.genresDao()
        )
        val repository =
            MoviesRepositoryImpl(remoteDataSource, localDataSource, Dispatchers.Default)
        val preferences = SearchPreferencesDataSource(requireContext().applicationContext)
        viewModel = ViewModelProvider(
            this,
            SearchViewModelFactory(repository, preferences)
        )[SearchViewModel::class.java]

        _binding = FragmentMoviesListBinding.bind(view)

        val listener = object : MoviesClickListener {
            override fun onItemClick(movieId: Int) {
                val bundle = Bundle()
                bundle.putInt(MOVIES_KEY, movieId)
                val detailsFragment = MovieDetailsFragment()
                detailsFragment.arguments = bundle
                requireActivity().supportFragmentManager.beginTransaction()
                    .addToBackStack(null)
                    .replace(R.id.main_container, detailsFragment)
                    .commit()
            }
        }

        adapter = MoviesAdapter(listener)
        binding.moviesListRecycler.adapter = adapter
        setupSearchInput()
        setupLayoutToggle()
        setupPageSizeDropdown()
        setupPagination()
        setupFilters()
        collectState()
    }

    private fun setupSearchInput() {
        binding.searchEditText.doOnTextChanged { text, _, _, _ ->
            if (!isUpdatingQuery) {
                viewModel.updateQuery(text?.toString().orEmpty())
            }
        }
    }

    private fun setupLayoutToggle() {
        binding.layoutToggleGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (isUpdatingLayout || !isChecked) return@addOnButtonCheckedListener
            val mode = when (checkedId) {
                R.id.layout_poster -> LayoutMode.POSTER
                R.id.layout_grid -> LayoutMode.GRID
                R.id.layout_list -> LayoutMode.LIST
                R.id.layout_backdrop -> LayoutMode.BACKDROP
                R.id.layout_compact -> LayoutMode.COMPACT
                else -> LayoutMode.POSTER
            }
            viewModel.setLayoutMode(mode)
        }
    }

    private fun setupPageSizeDropdown() {
        binding.pageSizeDropdown.setOnItemClickListener { _, _, position, _ ->
            val value = binding.pageSizeDropdown.adapter.getItem(position).toString().toIntOrNull()
            value?.let { viewModel.setPageSize(it) }
        }
    }

    private fun setupPagination() {
        binding.prevPageButton.setOnClickListener {
            if (latestState.page > 0) {
                viewModel.loadPage(latestState.page - 1)
            }
        }
        binding.nextPageButton.setOnClickListener {
            val maxPage = if (latestState.totalCount == 0) 0
            else (latestState.totalCount - 1) / latestState.pageSize
            if (latestState.page < maxPage) {
                viewModel.loadPage(latestState.page + 1)
            }
        }
    }

    private fun setupFilters() {
        binding.filtersButton.setOnClickListener {
            val sheet = SearchFilterBottomSheet().apply {
                state = latestState
                onApply = { filters -> viewModel.updateFilters(filters) }
            }
            sheet.show(parentFragmentManager, "filters")
        }
    }

    private fun collectState() {
        stateCollector?.cancel()
        stateCollector = viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(androidx.lifecycle.Lifecycle.State.STARTED) {
                viewModel.state.collectLatest { renderState(it) }
            }
        }
    }

    private fun renderState(state: SearchUiState) {
        latestState = state
        binding.searchProgressBar.visibility = if (state.isLoading) View.VISIBLE else View.GONE
        if (!state.isLoading && state.errorMessage != null && state.errorMessage != lastErrorMessage) {
            lastErrorMessage = state.errorMessage
            Toast.makeText(requireContext(), state.errorMessage, Toast.LENGTH_SHORT).show()
        } else if (state.errorMessage == null) {
            lastErrorMessage = null
        }

        if (binding.pageSizeDropdown.adapter == null) {
            val items = state.availablePageSizes.map { it.toString() }
            val adapter = android.widget.ArrayAdapter(
                requireContext(),
                android.R.layout.simple_dropdown_item_1line,
                items
            )
            binding.pageSizeDropdown.setAdapter(adapter)
        }

        if (binding.pageSizeDropdown.text.toString() != state.pageSize.toString()) {
            binding.pageSizeDropdown.setText(state.pageSize.toString(), false)
        }

        isUpdatingQuery = true
        if (binding.searchEditText.text?.toString() != state.query) {
            binding.searchEditText.setText(state.query)
            binding.searchEditText.setSelection(state.query.length)
        }
        isUpdatingQuery = false

        val checkedId = when (state.layoutMode) {
            LayoutMode.POSTER -> R.id.layout_poster
            LayoutMode.GRID -> R.id.layout_grid
            LayoutMode.LIST -> R.id.layout_list
            LayoutMode.BACKDROP -> R.id.layout_backdrop
            LayoutMode.COMPACT -> R.id.layout_compact
        }

        isUpdatingLayout = true
        if (binding.layoutToggleGroup.checkedButtonId != checkedId) {
            binding.layoutToggleGroup.check(checkedId)
        }
        isUpdatingLayout = false

        updateLayoutManager(state.layoutMode)
        adapter.layoutMode = state.layoutMode
        adapter.submitList(state.results)

        val maxPage = if (state.totalCount == 0) 0 else (state.totalCount - 1) / state.pageSize
        binding.pageIndicator.text = getString(
            R.string.page_indicator_format,
            state.page + 1,
            maxPage + 1,
            state.totalCount
        )
        binding.prevPageButton.isEnabled = state.page > 0
        binding.nextPageButton.isEnabled = state.page < maxPage
    }

    private fun updateLayoutManager(layoutMode: LayoutMode) {
        val isLandscape = resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE
        val layoutManager = when (layoutMode) {
            LayoutMode.POSTER -> GridLayoutManager(requireContext(), if (isLandscape) 3 else 2)
            LayoutMode.GRID -> GridLayoutManager(requireContext(), if (isLandscape) 4 else 3)
            LayoutMode.LIST -> LinearLayoutManager(requireContext())
            LayoutMode.BACKDROP -> LinearLayoutManager(requireContext())
            LayoutMode.COMPACT -> LinearLayoutManager(requireContext())
        }
        binding.moviesListRecycler.layoutManager = layoutManager
    }

    override fun onDestroyView() {
        stateCollector?.cancel()
        _binding = null
        super.onDestroyView()
    }
}