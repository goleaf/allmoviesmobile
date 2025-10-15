package dev.tutushkin.allmovies.presentation.movies.view

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.images.PosterImageLoaderFactory

class MoviesAdapter(
    private val clickListener: MoviesClickListener,
    private val posterImageLoaderFactory: PosterImageLoaderFactory,
) : ListAdapter<MovieList, MovieViewHolder>(
    MoviesListDiffCallback()
) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val binding = ViewHolderMovieBinding.inflate(layoutInflater, parent, false)
        val loader = posterImageLoaderFactory.create(binding.root)
        return MovieViewHolder(binding, loader)
    }

    override fun onBindViewHolder(holder: MovieViewHolder, position: Int) {
        val item = getItem(position)
        holder.bind(item, clickListener)
    }

    override fun onViewRecycled(holder: MovieViewHolder) {
        holder.clearPoster()
        super.onViewRecycled(holder)
    }
}

class MoviesListDiffCallback : DiffUtil.ItemCallback<MovieList>() {
    override fun areItemsTheSame(oldItem: MovieList, newItem: MovieList): Boolean {
        return oldItem.id == newItem.id
    }

    override fun areContentsTheSame(oldItem: MovieList, newItem: MovieList): Boolean {
        return oldItem == newItem
    }
}

interface MoviesClickListener {
    fun onItemClick(movieId: Int)
    fun onToggleFavorite(movieId: Int, isFavorite: Boolean)
}
