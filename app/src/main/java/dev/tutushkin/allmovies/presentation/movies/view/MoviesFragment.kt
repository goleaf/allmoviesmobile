package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Bundle
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.annotation.VisibleForTesting
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.GridLayoutManager
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.snackbar.Snackbar
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.appcompat.widget.SearchView
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule.moviesApi
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.data.sync.MoviesRefreshWorker
import dev.tutushkin.allmovies.databinding.FragmentMoviesListBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModelFactory
import dev.tutushkin.allmovies.utils.export.CsvExporter
import dev.tutushkin.allmovies.utils.export.ExportResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
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
    @VisibleForTesting
    internal var viewModelFactoryOverride: ViewModelProvider.Factory? = null
    private val viewModel: MoviesViewModel by viewModels {
        viewModelFactoryOverride ?: run {
            val application = requireActivity().application
            val db = MoviesDb.getDatabase(application)
            val localDataSource = MoviesLocalDataSourceImpl(
                db.moviesDao(),
                db.movieDetails(),
                db.actorsDao(),
                db.configurationDao(),
                db.genresDao()
            )
            val remoteDataSource = MoviesRemoteDataSourceImpl(moviesApi)
            val repository = MoviesRepositoryImpl(remoteDataSource, localDataSource, Dispatchers.Default)
            MoviesViewModelFactory(repository, languagePreferences)
        }
    }
    private var searchJob: Job? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

// TODO Column alignment RecyclerView
//        val displayMetrics = DisplayMetrics()
//            ...

        _binding = FragmentMoviesListBinding.bind(view)
        setHasOptionsMenu(true)
        csvExporter = CsvExporter(requireContext())

        val spanCount = when (resources.configuration.orientation) {
            Configuration.ORIENTATION_LANDSCAPE -> 3
            else -> 2
        }
        binding.moviesListRecycler.layoutManager = GridLayoutManager(requireContext(), spanCount)

        val listener = object : MoviesClickListener {
            override fun onItemClick(movieId: Int) {
                val bundle = Bundle()
                bundle.putInt(ARG_MOVIE_ID, movieId)
                val detailsFragment = MovieDetailsFragment()
                detailsFragment.arguments = bundle
                requireActivity().supportFragmentManager.beginTransaction()
                    .addToBackStack(null)
                    .replace(R.id.main_container, detailsFragment)
                    .commit()
            }

            override fun onToggleFavorite(movieId: Int, isFavorite: Boolean) {
                viewModel.toggleFavorite(movieId, isFavorite)
            }
        }

        adapter = MoviesAdapter(listener)
        binding.moviesListRecycler.adapter = adapter

        viewModel.movies.observe(viewLifecycleOwner, ::handleMoviesList)
        observeRefreshWork()
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        super.onCreateOptionsMenu(menu, inflater)
        inflater.inflate(R.menu.menu_movies_collection, menu)

        val searchItem = menu.findItem(R.id.action_search)
        val searchView = searchItem.actionView as? SearchView ?: return
        searchView.queryHint = getString(R.string.movies_search_hint)

        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                val text = query.orEmpty()
                performSearch(text)
                searchView.clearFocus()
                dismissKeyboard()
                return true
            }

            override fun onQueryTextChange(newText: String?): Boolean {
                val text = newText.orEmpty()
                searchJob?.cancel()
                if (text.isBlank()) {
                    viewModel.search(text)
                } else {
                    searchJob = viewLifecycleOwner.lifecycleScope.launch {
                        delay(SEARCH_DEBOUNCE_MS)
                        viewModel.search(text)
                    }
                }
                return true
            }
        })

        searchView.setOnQueryTextFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                dismissKeyboard()
            }
        }

        searchView.setOnCloseListener {
            searchJob?.cancel()
            viewModel.search("")
            dismissKeyboard()
            false
        }

        searchItem.setOnActionExpandListener(object : MenuItem.OnActionExpandListener {
            override fun onMenuItemActionExpand(item: MenuItem?): Boolean = true

            override fun onMenuItemActionCollapse(item: MenuItem?): Boolean {
                searchJob?.cancel()
                searchView.setQuery("", false)
                viewModel.refreshMovies(clearCache = false)
                dismissKeyboard()
                return true
            }
        })
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
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
            else -> super.onOptionsItemSelected(item)
        }
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
        when (state) {
            is MoviesState.Result -> {
                hideLoading()
                showMovies(state.result)
            }
            is MoviesState.Error -> {
                hideLoading()
                val message = state.e.message ?: getString(R.string.library_update_failed_generic)
                Snackbar.make(
                    binding.root,
                    message,
                    Snackbar.LENGTH_SHORT
                ).show()
                if (adapter.itemCount == 0) {
                    showEmpty(MoviesState.Empty(MoviesState.EmptyReason.NOW_PLAYING))
                }
            }
            is MoviesState.Loading -> showLoading()
            is MoviesState.Searching -> showLoading()
            is MoviesState.Empty -> {
                hideLoading()
                showEmpty(state)
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

    private fun showMovies(movies: List<MovieList>) {
        adapter.submitList(movies)
        binding.moviesListRecycler.isVisible = true
        binding.moviesListEmptyView.isVisible = false
    }

    private fun showEmpty(state: MoviesState.Empty) {
        adapter.submitList(emptyList())
        binding.moviesListRecycler.isVisible = false
        binding.moviesListEmptyView.isVisible = true
        binding.moviesListEmptyView.text = when (state.reason) {
            MoviesState.EmptyReason.NOW_PLAYING -> getString(R.string.movies_now_playing_empty)
            MoviesState.EmptyReason.SEARCH -> getString(
                R.string.movies_search_empty,
                state.query.orEmpty().replace("%", "%%")
            )
        }
    }

    private fun showLoading() {
        binding.moviesListProgress.isVisible = true
        binding.moviesListRecycler.isVisible = false
        binding.moviesListEmptyView.isVisible = false
    }

    private fun hideLoading() {
        binding.moviesListProgress.isVisible = false
    }

    private fun performSearch(query: String) {
        searchJob?.cancel()
        viewModel.search(query)
    }

    private fun dismissKeyboard() {
        val imm = requireContext().getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.hideSoftInputFromWindow(binding.root.windowToken, 0)
    }

    override fun onDestroyView() {
        searchJob?.cancel()
        _binding = null
        super.onDestroyView()
    }

    companion object {
        private const val SEARCH_DEBOUNCE_MS = 300L
    }
}