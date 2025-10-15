package dev.tutushkin.allmovies.presentation.movies.view

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import dev.tutushkin.allmovies.data.movies.ImageSizeSelector
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList

class MoviesAdapter(
    private val clickListener: MoviesClickListener,
    private val imageSizeSelector: ImageSizeSelector,
    private val itemWidthPx: Int,
    private val requestManagerFactory: PosterRequestManagerFactory = DefaultPosterRequestManagerFactory
) : ListAdapter<MovieList, MovieViewHolder>(
    MoviesListDiffCallback()
) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val binding = ViewHolderMovieBinding.inflate(layoutInflater, parent, false)
        val layoutParams = RecyclerView.LayoutParams(
            itemWidthPx.takeIf { it > 0 } ?: ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
        )
        binding.root.layoutParams = layoutParams
        return MovieViewHolder(binding, imageSizeSelector, requestManagerFactory)
    }

    override fun onBindViewHolder(holder: MovieViewHolder, position: Int) {
        val item = getItem(position)
        holder.bind(item, clickListener)
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
