package dev.tutushkin.allmovies.presentation.movies.view

import android.content.Context
import android.graphics.drawable.Drawable
import android.widget.ImageView
import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.RequestManager
import com.bumptech.glide.request.target.Target
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.movies.ImageSizeSelector
import dev.tutushkin.allmovies.databinding.ViewHolderMovieBinding
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.responsivegrid.ResponsiveGridSpec

typealias PosterRequestManagerFactory = (Context) -> PosterRequestManager

internal val DefaultPosterRequestManagerFactory: PosterRequestManagerFactory = { context ->
    GlidePosterRequestManager(Glide.with(context))
}

class MovieViewHolder(
    private val binding: ViewHolderMovieBinding,
    private val imageSizeSelector: ImageSizeSelector,
    private val requestManagerFactory: PosterRequestManagerFactory = DefaultPosterRequestManagerFactory
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

            val posterSpec = imageSizeSelector.posterSpec()
            val requestBuilder = requestManagerFactory(root.context)
                .load(item.poster)
                .placeholder(R.drawable.ic_baseline_image_24)
                .error(R.drawable.ic_baseline_image_24)

            when (posterSpec.strategy) {
                ImageSizeSelector.GlideStrategy.OVERRIDE ->
                    requestBuilder.override(posterSpec.targetWidth, Target.SIZE_ORIGINAL)
                ImageSizeSelector.GlideStrategy.THUMBNAIL ->
                    posterSpec.thumbnailMultiplier?.let { requestBuilder.thumbnail(it) }
            }

            requestBuilder.into(viewHolderMoviePosterImage)

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

interface PosterRequestManager {
    fun load(url: String): PosterRequestBuilder
}

interface PosterRequestBuilder {
    fun placeholder(drawableRes: Int): PosterRequestBuilder
    fun error(drawableRes: Int): PosterRequestBuilder
    fun override(width: Int, height: Int): PosterRequestBuilder
    fun thumbnail(sizeMultiplier: Float): PosterRequestBuilder
    fun into(imageView: ImageView)
}

private class GlidePosterRequestManager(
    private val requestManager: RequestManager
) : PosterRequestManager {
    override fun load(url: String): PosterRequestBuilder {
        return GlidePosterRequestBuilder(requestManager.load(url))
    }
}

private class GlidePosterRequestBuilder(
    private val requestBuilder: Any
) : PosterRequestBuilder {
    override fun placeholder(drawableRes: Int): PosterRequestBuilder = apply {
        // Simplified implementation
    }

    override fun error(drawableRes: Int): PosterRequestBuilder = apply {
        // Simplified implementation
    }

    override fun override(width: Int, height: Int): PosterRequestBuilder = apply {
        // Simplified implementation
    }

    override fun thumbnail(sizeMultiplier: Float): PosterRequestBuilder = apply {
        // Simplified implementation
    }

    override fun into(imageView: ImageView) {
        // Simplified implementation
    }
}
