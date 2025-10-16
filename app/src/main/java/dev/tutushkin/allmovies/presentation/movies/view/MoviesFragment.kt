package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import androidx.appcompat.widget.SearchView
import androidx.annotation.VisibleForTesting
import androidx.core.os.bundleOf
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.GridLayoutManager
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.snackbar.Snackbar
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.movies.createImageSizeSelector
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.data.sync.MoviesRefreshWorker
import dev.tutushkin.allmovies.databinding.FragmentMoviesListBinding
import dev.tutushkin.allmovies.presentation.favorites.view.FavoritesFragment
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesSearchState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.provideMoviesViewModelFactory
import dev.tutushkin.allmovies.utils.export.CsvExporter
import dev.tutushkin.allmovies.utils.export.ExportResult
import androidx.window.layout.WindowMetricsCalculator
import kotlinx.coroutines.launch
import kotlinx.serialization.ExperimentalSerializationApi
import kotlin.LazyThreadSafetyMode

@ExperimentalSerializationApi
class MoviesFragment : Fragment(R.layout.fragment_movies_list) {

    private var _binding: FragmentMoviesListBinding? = null
    private val binding get() = _binding!!

    private lateinit var adapter: MoviesAdapter
    private lateinit var csvExporter: CsvExporter
    private val workManager: WorkManager by lazy { WorkManager.getInstance(requireContext()) }
    private val languagePreferences: LanguagePreferences by lazy(LazyThreadSafetyMode.NONE) {
        LanguagePreferences(requireContext().applicationContext)
    }
    private var isSearchActive: Boolean = false
    private var searchMenuItem: MenuItem? = null
    private var searchView: SearchView? = null
    @VisibleForTesting
    internal var viewModelFactoryOverride: ViewModelProvider.Factory? = null
    private val viewModel: MoviesViewModel by activityViewModels {
        viewModelFactoryOverride
            ?: defaultViewModelFactoryOverride
            ?: provideMoviesViewModelFactory()
    }

    companion object {
        @VisibleForTesting
        var defaultViewModelFactoryOverride: ViewModelProvider.Factory? = null
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        _binding = FragmentMoviesListBinding.bind(view)
        csvExporter = CsvExporter(requireContext())

        setupToolbarMenu()

        val windowMetrics = WindowMetricsCalculator.getOrCreate()
            .computeCurrentWindowMetrics(requireActivity())
        val density = resources.displayMetrics.density
        val spacingDp = resources.getDimension(R.dimen.movies_grid_spacing) / density
        val gridConfig = ResponsiveGridCalculatorProvider.calculator
            .calculate(windowMetrics, density, spacingDp)

        binding.moviesListRecycler.layoutManager = GridLayoutManager(
            requireContext(),
            gridConfig.spanCount,
        )
        binding.moviesListRecycler.addItemDecoration(
            SpacingItemDecoration(gridConfig.spanCount, gridConfig.spacingPx),
        )
        val listener = object : MoviesClickListener {
            override fun onItemClick(movieId: Int) {
                val args = bundleOf(ARG_MOVIE_ID to movieId)
                if (findNavController().currentDestination?.id == R.id.moviesFragment) {
                    findNavController().navigate(R.id.action_moviesFragment_to_movieDetailsFragment, args)
                }
            }

            override fun onToggleFavorite(movieId: Int, isFavorite: Boolean) {
                viewModel.toggleFavorite(movieId, isFavorite)
            }
        }

        val imageSizeSelector = requireContext().createImageSizeSelector()
        adapter = MoviesAdapter(listener, imageSizeSelector, gridConfig.itemWidthPx)
        binding.moviesListRecycler.adapter = adapter

        viewModel.movies.observe(viewLifecycleOwner, ::handleMoviesList)
        viewModel.searchState.observe(viewLifecycleOwner, ::handleSearchState)
        observeRefreshWork()
    }

    private fun setupToolbarMenu() {
        val toolbar = binding.moviesListToolbar
        toolbar.inflateMenu(R.menu.menu_movies_collection)

        val searchItem = toolbar.menu.findItem(R.id.action_search)
        val searchView = searchItem?.actionView as? SearchView
        if (searchView != null) {
            this.searchMenuItem = searchItem
            this.searchView = searchView
            searchView.queryHint = getString(R.string.movies_search_query_hint)
            searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
                override fun onQueryTextSubmit(query: String?): Boolean {
                    viewModel.observeSearch(query.orEmpty())
                    searchView.clearFocus()
                    return true
                }

                override fun onQueryTextChange(newText: String?): Boolean {
                    viewModel.observeSearch(newText.orEmpty())
                    return true
                }
            })

            searchItem.setOnActionExpandListener(object : MenuItem.OnActionExpandListener {
                override fun onMenuItemActionExpand(item: MenuItem?): Boolean {
                    isSearchActive = true
                    return true
                }

                override fun onMenuItemActionCollapse(item: MenuItem?): Boolean {
                    isSearchActive = false
                    searchView.setQuery("", false)
                    viewModel.observeSearch("")
                    return true
                }
            })
        }

        toolbar.setOnMenuItemClickListener { menuItem ->
            when (menuItem.itemId) {
                R.id.action_update_all -> {
                    enqueueLibraryRefresh()
                    true
                }
                R.id.action_export -> {
                    exportLibrary()
                    true
                }
                R.id.action_language -> {
                    showLanguageSelectionDialog()
                    true
                }
                R.id.action_favorites -> {
                    requireActivity().supportFragmentManager.beginTransaction()
                        .addToBackStack(null)
                        .replace(R.id.main_container, FavoritesFragment())
                        .commit()
                    true
                }
                else -> false
            }
        })
    }


    private fun showLanguageSelectionDialog() {
        val entries = resources.getStringArray(R.array.language_entries)
        val values = resources.getStringArray(R.array.language_values)
        if (entries.isEmpty() || values.isEmpty()) {
            return
        }

        val currentCode = languagePreferences.getSelectedLanguage()
        var selectedIndex = values.indexOfFirst { it.equals(currentCode, ignoreCase = true) }
        if (selectedIndex < 0) {
            selectedIndex = 0
        }

        MaterialAlertDialogBuilder(requireContext())
            .setTitle(R.string.language_dialog_title)
            .setSingleChoiceItems(entries, selectedIndex) { _, which ->
                selectedIndex = which
            }
            .setPositiveButton(android.R.string.ok) { dialog, _ ->
                val newCode = values.getOrNull(selectedIndex) ?: return@setPositiveButton
                if (!newCode.equals(currentCode, ignoreCase = true)) {
                    languagePreferences.setSelectedLanguage(newCode)
                    viewModel.changeLanguage(newCode)
                }
                dialog.dismiss()
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    private fun handleMoviesList(state: MoviesState) {
        if (isSearchActive && state !is MoviesState.Loading) {
            return
        }

        when (state) {
            is MoviesState.Result -> {
                hideLoading()
                adapter.submitList(state.result)
                hideEmptyState()
            }
            is MoviesState.Error -> {
                hideLoading()
                val message = state.e.message ?: getString(R.string.library_update_failed_generic)
                Snackbar.make(
                    binding.root,
                    message,
                    Snackbar.LENGTH_SHORT
                ).show()
                hideEmptyState()
            }
            is MoviesState.Loading -> {
                showLoading()
            }
        }
    }

    private fun handleSearchState(state: MoviesSearchState) {
        isSearchActive = state !is MoviesSearchState.Idle

        when (state) {
            MoviesSearchState.Idle -> {
                hideLoading()
                hideEmptyState()
                binding.moviesListRecycler.isVisible = true
                viewModel.movies.value?.let(::handleMoviesList)
            }
            MoviesSearchState.Loading -> {
                showLoading()
                hideEmptyState()
            }
            is MoviesSearchState.Result -> {
                hideLoading()
                hideEmptyState()
                binding.moviesListRecycler.isVisible = true
                adapter.submitList(state.result)
            }
            is MoviesSearchState.Empty -> {
                hideLoading()
                adapter.submitList(emptyList())
                showEmptyState(getString(R.string.movies_search_empty_state, state.query))
            }
            is MoviesSearchState.Error -> {
                hideLoading()
                adapter.submitList(emptyList())
                hideEmptyState()
                val reason = state.cause.localizedMessage
                val message = if (!reason.isNullOrBlank()) {
                    getString(R.string.movies_search_error_with_reason, state.query, reason)
                } else {
                    getString(R.string.movies_search_error, state.query)
                }
                Snackbar.make(
                    binding.root,
                    message,
                    Snackbar.LENGTH_SHORT
                ).show()
            }
        }
    }

    private fun observeRefreshWork() {
        workManager.getWorkInfosByTagLiveData(MoviesRefreshWorker.WORK_TAG)
            .observe(viewLifecycleOwner) { infos ->
                val info = infos.firstOrNull() ?: run {
                    hideLibraryStatus()
                    return@observe
                }

                when (info.state) {
                    WorkInfo.State.ENQUEUED, WorkInfo.State.BLOCKED -> {
                        updateLibraryStatus(0, 0, "")
                    }
                    WorkInfo.State.RUNNING -> {
                        val current = info.progress.getInt(MoviesRefreshWorker.PROGRESS_CURRENT, 0)
                        val total = info.progress.getInt(MoviesRefreshWorker.PROGRESS_TOTAL, 0)
                        val title = info.progress.getString(MoviesRefreshWorker.PROGRESS_TITLE) ?: ""
                        updateLibraryStatus(current, total, title)
                    }
                    WorkInfo.State.SUCCEEDED -> {
                        hideLibraryStatus()
                        Snackbar.make(
                            binding.root,
                            getString(R.string.library_update_complete_toast),
                            Snackbar.LENGTH_SHORT
                        ).show()
                    }
                    WorkInfo.State.FAILED -> {
                        hideLibraryStatus()
                        val error = info.outputData.getString(MoviesRefreshWorker.KEY_ERROR_MESSAGE)
                            ?: getString(R.string.library_update_failed_generic)
                        Snackbar.make(
                            binding.root,
                            getString(R.string.library_update_failed_toast, error),
                            Snackbar.LENGTH_LONG
                        ).show()
                    }
                    WorkInfo.State.CANCELLED -> hideLibraryStatus()
                }
            }
    }

    private fun enqueueLibraryRefresh() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val request = OneTimeWorkRequestBuilder<MoviesRefreshWorker>()
            .setConstraints(constraints)
            .addTag(MoviesRefreshWorker.WORK_TAG)
            .build()

        workManager.enqueueUniqueWork(
            MoviesRefreshWorker.WORK_NAME,
            ExistingWorkPolicy.REPLACE,
            request
        )
    }

    private fun exportLibrary() {
        lifecycleScope.launch {
            showExportInProgress()
            try {
                val result = csvExporter.exportLibrary()
                hideLibraryStatus()
                shareExportResult(result)
            } catch (throwable: Throwable) {
                hideLibraryStatus()
                val message = throwable.localizedMessage
                    ?: getString(R.string.library_update_failed_generic)
                Snackbar.make(
                    binding.root,
                    getString(R.string.library_export_failed, message),
                    Snackbar.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun shareExportResult(result: ExportResult) {
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = result.mimeType
            putExtra(Intent.EXTRA_STREAM, result.uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        val resolveInfos = requireContext().packageManager.queryIntentActivities(
            shareIntent,
            PackageManager.MATCH_DEFAULT_ONLY
        )
        resolveInfos.forEach { info ->
            requireContext().grantUriPermission(
                info.activityInfo.packageName,
                result.uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        }

        startActivity(Intent.createChooser(shareIntent, getString(R.string.library_export_share_title)))
    }

    private fun resetSearch() {
        searchView?.apply {
            setQuery("", false)
            clearFocus()
        }
        viewModel.observeSearch("")
        searchMenuItem?.collapseActionView()
    }

    private fun updateLibraryStatus(current: Int, total: Int, title: String) {
        binding.libraryStatusContainer.isVisible = true
        if (total <= 0) {
            binding.libraryStatusProgress.isIndeterminate = true
            binding.libraryStatusProgress.progress = 0
            binding.libraryStatusMessage.text = getString(R.string.library_update_preparing)
        } else {
            val safeCurrent = current.coerceAtMost(total)
            val percent = ((safeCurrent.toFloat() / total) * 100).toInt()
            binding.libraryStatusProgress.isIndeterminate = false
            binding.libraryStatusProgress.progress = percent
            val movieTitle = if (title.isNotBlank()) title else getString(R.string.library_update_unknown_title)
            binding.libraryStatusMessage.text = getString(
                R.string.library_update_progress,
                percent,
                movieTitle
            )
        }
    }

    private fun showExportInProgress() {
        binding.libraryStatusContainer.isVisible = true
        binding.libraryStatusProgress.isIndeterminate = true
        binding.libraryStatusProgress.progress = 0
        binding.libraryStatusMessage.text = getString(R.string.library_export_in_progress)
    }

    private fun hideLibraryStatus() {
        binding.libraryStatusContainer.isVisible = false
    }

    private fun showLoading() {
        binding.moviesListLoadingContainer.isVisible = true
        binding.moviesListRecycler.apply {
            isEnabled = false
            isClickable = false
            suppressLayout(true)
        }
        hideEmptyState()
    }

    private fun hideLoading() {
        binding.moviesListLoadingContainer.isVisible = false
        binding.moviesListRecycler.apply {
            isEnabled = true
            isClickable = true
            suppressLayout(false)
            isVisible = true
        }
    }

    private fun showEmptyState(message: String) {
        binding.moviesListRecycler.isVisible = false
        binding.moviesListEmptyMessage.apply {
            text = message
            isVisible = true
        }
    }

    private fun hideEmptyState() {
        binding.moviesListEmptyMessage.isVisible = false
        binding.moviesListRecycler.isVisible = true
    }

    override fun onDestroyView() {
        searchView = null
        searchMenuItem = null
        _binding = null
        super.onDestroyView()
    }
}