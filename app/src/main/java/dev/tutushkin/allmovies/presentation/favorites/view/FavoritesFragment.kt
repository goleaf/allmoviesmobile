package dev.tutushkin.allmovies.presentation.favorites.view

import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import androidx.annotation.VisibleForTesting
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
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.movies.view.MoviesAdapter
import dev.tutushkin.allmovies.presentation.movies.view.MoviesClickListener
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.provideMoviesViewModelFactory
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
        favoritesViewModelFactoryOverride ?: provideFavoritesViewModelFactory()
    }

    private val moviesViewModel: MoviesViewModel by activityViewModels {
        moviesViewModelFactoryOverride ?: provideMoviesViewModelFactory()
    }

    private lateinit var adapter: MoviesAdapter

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

        adapter = MoviesAdapter(listener)
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
        val bundle = Bundle().apply {
            putInt(ARG_MOVIE_ID, movieId)
        }
        val fragment = MovieDetailsFragment().apply {
            arguments = bundle
        }
        requireActivity().supportFragmentManager.beginTransaction()
            .addToBackStack(null)
            .replace(R.id.main_container, fragment)
            .commit()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
