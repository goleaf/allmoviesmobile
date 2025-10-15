package dev.tutushkin.allmovies.presentation.movies.view

import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.images.PosterImageLoader

class MovieViewHolder(
    private val binding: ViewHolderMovieBinding,
    private val posterImageLoader: PosterImageLoader,
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
            val certificationText = item.certification.label.ifBlank { item.certification.code }
            viewHolderMovieAgeText.isVisible = certificationText.isNotBlank()
            viewHolderMovieAgeText.text = certificationText
            viewHolderMovieRating.rating = item.ratings / 2
            posterImageLoader.loadPoster(viewHolderMoviePosterImage, item.poster)

            root.setOnClickListener { clickListener.onItemClick(item.id) }
            viewHolderMovieLikeImage.isVisible = true
            val favoriteIcon = if (item.isFavorite) R.drawable.ic_like else R.drawable.ic_notlike
            viewHolderMovieLikeImage.setImageResource(favoriteIcon)
            val favoriteDescription = if (item.isFavorite) {
                root.context.getString(R.string.movies_list_favorite_remove)
            } else {
                root.context.getString(R.string.movies_list_favorite_add)
            }
            viewHolderMovieLikeImage.contentDescription = favoriteDescription
            viewHolderMovieLikeImage.setOnClickListener {
                clickListener.onToggleFavorite(item.id, !item.isFavorite)
            }
        }
    }

    fun clearPoster() {
        posterImageLoader.clear(binding.viewHolderMoviePosterImage)
    }
}
