package dev.tutushkin.allmovies.presentation.favorites.view

import android.os.Bundle
import android.view.View
import androidx.annotation.VisibleForTesting
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.GridLayoutManager
import com.google.android.material.snackbar.Snackbar
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.databinding.FragmentFavoritesListBinding
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.FavoritesState
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.FavoritesViewModel
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.provideFavoritesViewModelFactory
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.movies.view.MoviesAdapter
import dev.tutushkin.allmovies.presentation.movies.view.MoviesClickListener
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.provideMoviesViewModelFactory
import dev.tutushkin.allmovies.presentation.responsivegrid.ResponsiveGridCalculator
import dev.tutushkin.allmovies.presentation.responsivegrid.ResponsiveGridProvider
import dev.tutushkin.allmovies.presentation.responsivegrid.ResponsiveGridSpacingItemDecoration
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class FavoritesFragment : Fragment(R.layout.fragment_favorites_list) {

    private var _binding: FragmentFavoritesListBinding? = null
    private val binding get() = _binding!!

    @VisibleForTesting
    internal var favoritesViewModelFactoryOverride: ViewModelProvider.Factory? = null

    @VisibleForTesting
    internal var moviesViewModelFactoryOverride: ViewModelProvider.Factory? = null

    private val favoritesViewModel: FavoritesViewModel by viewModels {
        favoritesViewModelFactoryOverride
            ?: defaultFavoritesViewModelFactoryOverride
            ?: provideFavoritesViewModelFactory()
    }

    private val moviesViewModel: MoviesViewModel by activityViewModels {
        moviesViewModelFactoryOverride
            ?: defaultMoviesViewModelFactoryOverride
            ?: provideMoviesViewModelFactory()
    }

    private lateinit var adapter: MoviesAdapter

    companion object {
        @VisibleForTesting
        var defaultFavoritesViewModelFactoryOverride: ViewModelProvider.Factory? = null

        @VisibleForTesting
        var defaultMoviesViewModelFactoryOverride: ViewModelProvider.Factory? = null
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentFavoritesListBinding.bind(view)

        val listener = object : MoviesClickListener {
            override fun onItemClick(movieId: Int) {
                navigateToDetails(movieId)
            }

            override fun onToggleFavorite(movieId: Int, isFavorite: Boolean) {
                moviesViewModel.toggleFavorite(movieId, isFavorite) { success ->
                    if (!success && isAdded) {
                        Snackbar.make(binding.root, R.string.favorites_list_error_generic, Snackbar.LENGTH_SHORT)
                            .show()
                    }
                }
            }
        }

        adapter = MoviesAdapter(listener)
        val spacing = resources.getDimensionPixelSize(R.dimen.movie_grid_spacing)
        val calculator = ResponsiveGridCalculator(
            minimumCellWidthPx = resources.getDimensionPixelSize(R.dimen.movie_grid_min_item_width),
            horizontalSpacingPx = spacing,
        )
        val gridSpec = ResponsiveGridProvider(requireActivity(), calculator).calculate()
        val layoutManager = GridLayoutManager(requireContext(), gridSpec.spanCount)
        binding.favoritesListRecycler.layoutManager = layoutManager
        binding.favoritesListRecycler.clipToPadding = false
        while (binding.favoritesListRecycler.itemDecorationCount > 0) {
            binding.favoritesListRecycler.removeItemDecorationAt(0)
        }
        binding.favoritesListRecycler.addItemDecoration(ResponsiveGridSpacingItemDecoration(spacing))
        binding.favoritesListRecycler.adapter = adapter
        adapter.updateGridSpec(gridSpec)

        favoritesViewModel.favorites.observe(viewLifecycleOwner, ::renderState)
    }

    private fun renderState(state: FavoritesState) {
        when (state) {
            is FavoritesState.Loading -> {
                binding.favoritesListLoading.visibility = View.VISIBLE
                binding.favoritesListEmpty.visibility = View.GONE
                binding.favoritesListError.visibility = View.GONE
            }
            is FavoritesState.Result -> {
                binding.favoritesListLoading.visibility = View.GONE
                binding.favoritesListEmpty.visibility = View.GONE
                binding.favoritesListError.visibility = View.GONE
                adapter.submitList(state.movies)
            }
            is FavoritesState.Empty -> {
                binding.favoritesListLoading.visibility = View.GONE
                binding.favoritesListError.visibility = View.GONE
                binding.favoritesListEmpty.visibility = View.VISIBLE
                adapter.submitList(emptyList())
            }
            is FavoritesState.Error -> {
                binding.favoritesListLoading.visibility = View.GONE
                binding.favoritesListEmpty.visibility = View.GONE
                binding.favoritesListError.visibility = View.VISIBLE
                binding.favoritesListError.text =
                    state.throwable.message ?: getString(R.string.favorites_list_error_generic)
                adapter.submitList(emptyList())
            }
        }
    }

    private fun navigateToDetails(movieId: Int) {
        val args = bundleOf(ARG_MOVIE_ID to movieId)
        if (findNavController().currentDestination?.id == R.id.favoritesFragment) {
            findNavController().navigate(R.id.action_favoritesFragment_to_movieDetailsFragment, args)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
