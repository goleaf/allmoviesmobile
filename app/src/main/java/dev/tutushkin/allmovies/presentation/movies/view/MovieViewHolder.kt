package dev.tutushkin.allmovies.presentation.movies.view

import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.responsivegrid.ResponsiveGridSpec

class MovieViewHolder(
    private val binding: ViewHolderMovieBinding,
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: MovieList, clickListener: MoviesClickListener, gridSpec: ResponsiveGridSpec?) {
        binding.apply {
            gridSpec?.let { spec ->
                root.updateLayoutParams<RecyclerView.LayoutParams> {
                    width = spec.cellWidthPx
                }
            }
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
            Glide.with(root.context)
                .load(item.poster)
                .placeholder(R.drawable.ic_baseline_image_24)
                .error(R.drawable.ic_baseline_image_24)
                .into(viewHolderMoviePosterImage)

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
}
