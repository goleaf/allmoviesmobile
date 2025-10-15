package dev.tutushkin.allmovies.presentation.movies.view

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBackdropBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieCompactBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieGridBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieListBinding
import dev.tutushkin.allmovies.domain.movies.models.LayoutMode
import dev.tutushkin.allmovies.domain.movies.models.MovieList

class MoviesAdapter(
    private val clickListener: MoviesClickListener
) : ListAdapter<MovieList, RecyclerView.ViewHolder>(
    MoviesListDiffCallback()
) {

    var layoutMode: LayoutMode = LayoutMode.POSTER
        set(value) {
            if (field != value) {
                field = value
                notifyDataSetChanged()
            }
        }

    override fun getItemViewType(position: Int): Int = layoutMode.ordinal

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return when (LayoutMode.values()[viewType]) {
            LayoutMode.POSTER -> PosterMovieViewHolder(
                ViewHolderMovieBinding.inflate(inflater, parent, false)
            )
            LayoutMode.GRID -> GridMovieViewHolder(
                ViewHolderMovieGridBinding.inflate(inflater, parent, false)
            )
            LayoutMode.LIST -> ListMovieViewHolder(
                ViewHolderMovieListBinding.inflate(inflater, parent, false)
            )
            LayoutMode.BACKDROP -> BackdropMovieViewHolder(
                ViewHolderMovieBackdropBinding.inflate(inflater, parent, false)
            )
            LayoutMode.COMPACT -> CompactMovieViewHolder(
                ViewHolderMovieCompactBinding.inflate(inflater, parent, false)
            )
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val item = getItem(position)
        when (holder) {
            is PosterMovieViewHolder -> holder.bind(item, clickListener)
            is GridMovieViewHolder -> holder.bind(item, clickListener)
            is ListMovieViewHolder -> holder.bind(item, clickListener)
            is BackdropMovieViewHolder -> holder.bind(item, clickListener)
            is CompactMovieViewHolder -> holder.bind(item, clickListener)
        }
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
}
