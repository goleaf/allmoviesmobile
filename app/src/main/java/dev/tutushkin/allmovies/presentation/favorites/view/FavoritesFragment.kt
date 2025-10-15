package dev.tutushkin.allmovies.presentation.favorites.view

import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import androidx.annotation.VisibleForTesting
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.GridLayoutManager
import com.google.android.material.snackbar.Snackbar
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.databinding.FragmentFavoritesListBinding
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.FavoritesState
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.FavoritesViewModel
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.provideFavoritesViewModelFactory
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.data.movies.createImageSizeSelector
import dev.tutushkin.allmovies.presentation.movies.view.MoviesAdapter
import dev.tutushkin.allmovies.presentation.movies.view.MoviesClickListener
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.provideMoviesViewModelFactory
import kotlinx.serialization.ExperimentalSerializationApi
import androidx.navigation.fragment.findNavController

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

        val spanCount = when (resources.configuration.orientation) {
            Configuration.ORIENTATION_LANDSCAPE -> 3
            else -> 2
        }

        binding.favoritesListRecycler.layoutManager = GridLayoutManager(requireContext(), spanCount)

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

        val imageSizeSelector = requireContext().createImageSizeSelector()
        adapter = MoviesAdapter(listener, imageSizeSelector)
        binding.favoritesListRecycler.adapter = adapter

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
