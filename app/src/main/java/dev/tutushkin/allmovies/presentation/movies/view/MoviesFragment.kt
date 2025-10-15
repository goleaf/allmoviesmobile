package dev.tutushkin.allmovies.presentation.movies.view

import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.GridLayoutManager
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.auth.AuthServiceLocator
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule.moviesApi
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.databinding.FragmentMoviesListBinding
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.presentation.movies.viewmodel.CollectionAccessState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesState
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModelFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

const val MOVIES_KEY = "MOVIES"

@ExperimentalSerializationApi
class MoviesFragment : Fragment(R.layout.fragment_movies_list) {

    private var _binding: FragmentMoviesListBinding? = null
    private val binding get() = _binding!!

    private lateinit var adapter: MoviesAdapter
    private lateinit var viewModel: MoviesViewModel

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
        val authRepository = AuthServiceLocator.provideRepository(requireContext())
        viewModel = ViewModelProvider(
            this,
            MoviesViewModelFactory(repository, authRepository)
        )[MoviesViewModel::class.java]

        _binding = FragmentMoviesListBinding.bind(view)

        val spanCount = when (resources.configuration.orientation) {
            Configuration.ORIENTATION_LANDSCAPE -> 3
            else -> 2
        }
        binding.moviesListRecycler.layoutManager = GridLayoutManager(requireContext(), spanCount)

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

        viewModel.movies.observe(viewLifecycleOwner, ::handleMoviesList)
        viewModel.collectionState.observe(viewLifecycleOwner, ::handleCollectionState)
    }

    private fun handleMoviesList(state: MoviesState) {
        when (state) {
            is MoviesState.Result -> {
//                hideLoading()
//                Toast.makeText(requireContext(), "Success", Toast.LENGTH_SHORT).show()
                adapter.submitList(state.result)
            }
            is MoviesState.Error -> {
//                hideLoading()
                Toast.makeText(requireContext(), state.e.message, Toast.LENGTH_SHORT).show()
            }
            is MoviesState.Loading -> //showLoading()
            {
//                showLoading()
//                Toast.makeText(requireContext(), "Loading...", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun handleCollectionState(state: CollectionAccessState) {
        when (state) {
            CollectionAccessState.Visible -> {
                binding.moviesListRecycler.visibility = View.VISIBLE
                binding.moviesGuestMessage.visibility = View.GONE
            }
            CollectionAccessState.Hidden -> {
                binding.moviesListRecycler.visibility = View.GONE
                binding.moviesGuestMessage.visibility = View.VISIBLE
                adapter.submitList(emptyList())
            }
        }
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    companion object {
        private const val ARG_GUEST_MODE = "arg_guest_mode"

        fun newInstance(isGuest: Boolean): MoviesFragment {
            return MoviesFragment().apply {
                arguments = Bundle().apply { putBoolean(ARG_GUEST_MODE, isGuest) }
            }
        }
    }
}