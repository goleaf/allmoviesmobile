package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBackdropBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieCompactBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieGridBinding
import dev.tutushkin.allmovies.databinding.ViewHolderMovieListBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList

class PosterMovieViewHolder(
    private val binding: ViewHolderMovieBinding,
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: MovieList, clickListener: MoviesClickListener) {
        binding.apply {
            viewHolderMovieTitleText.text = item.title
            viewHolderMovieGenresText.text = item.genres
            viewHolderMovieYearText.text = item.year.ifBlank {
                root.context.getString(R.string.movies_list_year_unknown)
            }
            viewHolderMovieReviewsText.text =
                root.context.getString(R.string.movies_list_reviews, item.numberOfRatings)
            viewHolderMovieAgeText.text = item.minimumAge
            viewHolderMovieRating.rating = item.ratings / 2
            Glide.with(root.context)
                .load(item.poster)
                .placeholder(R.drawable.ic_baseline_image_24)
                .error(R.drawable.ic_baseline_image_24)
                .into(viewHolderMoviePosterImage)

            root.setOnClickListener { clickListener.onItemClick(item.id) }
        }
    }
}

class GridMovieViewHolder(
    private val binding: ViewHolderMovieGridBinding,
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: MovieList, clickListener: MoviesClickListener) {
        binding.movieTitle.text = item.title
        binding.movieGenres.text = item.genres
        binding.movieMeta.text = item.meta(binding.root.context)
        Glide.with(binding.root.context)
            .load(item.poster)
            .placeholder(R.drawable.ic_baseline_image_24)
            .error(R.drawable.ic_baseline_image_24)
            .into(binding.moviePoster)
        binding.root.setOnClickListener { clickListener.onItemClick(item.id) }
    }
}

class ListMovieViewHolder(
    private val binding: ViewHolderMovieListBinding,
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: MovieList, clickListener: MoviesClickListener) {
        binding.movieTitle.text = item.title
        binding.moviePlot.text = item.plot
        binding.movieMeta.text = item.meta(binding.root.context)
        Glide.with(binding.root.context)
            .load(item.poster)
            .placeholder(R.drawable.ic_baseline_image_24)
            .error(R.drawable.ic_baseline_image_24)
            .into(binding.moviePoster)
        binding.root.setOnClickListener { clickListener.onItemClick(item.id) }
    }
}

class BackdropMovieViewHolder(
    private val binding: ViewHolderMovieBackdropBinding,
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: MovieList, clickListener: MoviesClickListener) {
        binding.movieTitle.text = item.title
        binding.movieMeta.text = item.meta(binding.root.context)
        binding.moviePlot.text = item.plot
        Glide.with(binding.root.context)
            .load(item.poster)
            .placeholder(R.drawable.ic_baseline_image_24)
            .error(R.drawable.ic_baseline_image_24)
            .into(binding.movieBackdrop)
        binding.root.setOnClickListener { clickListener.onItemClick(item.id) }
    }
}

class CompactMovieViewHolder(
    private val binding: ViewHolderMovieCompactBinding,
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: MovieList, clickListener: MoviesClickListener) {
        binding.movieTitle.text = item.title
        binding.movieMeta.text = item.meta(binding.root.context)
        binding.root.setOnClickListener { clickListener.onItemClick(item.id) }
    }
}

private fun MovieList.meta(context: Context): String {
    val parts = mutableListOf<String>()
    if (year.isNotBlank()) {
        parts += year
    }
    if (format.isNotBlank()) {
        parts += format
    }
    if (minimumAge.isNotBlank()) {
        parts += minimumAge
    }
    parts += context.getString(R.string.movies_list_reviews, numberOfRatings)
    return parts.joinToString(separator = " • ")
}
