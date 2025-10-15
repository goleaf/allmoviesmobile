package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.local.*
import dev.tutushkin.allmovies.data.movies.remote.*
import dev.tutushkin.allmovies.domain.movies.models.Genre
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

internal fun MovieListDto.toEntity(): MovieListEntity = MovieListEntity(
    id = this.id,
    title = this.title,
    poster = getImageUrl(this.posterPath),
    ratings = this.voteAverage,
    numberOfRatings = this.voteCount,
    minimumAge = normalizeAge(this.adult),
    year = dateToYear(this.releaseDate),
    genres = filterGenres(this.genreIds)
)

internal fun MovieDetailsResponse.toEntity(): MovieDetailsEntity = MovieDetailsEntity(
    id = this.id,
    title = this.title,
    overview = this.overview,
    poster = getImageUrl(this.posterPath),
    backdrop = getImageUrl(this.backdropPath),
    ratings = this.voteAverage,
    numberOfRatings = this.voteCount,
    minimumAge = normalizeAge(this.adult),
    year = dateToYear(this.releaseDate),
    runtime = this.runtime,
    genres = this.genres.joinToString { it.name },
    imdbId = this.imdbId.orEmpty()
)

internal fun MovieActorDto.toEntity(): ActorEntity = ActorEntity(
    id = this.id,
    name = this.name,
    photo = getImageUrl(this.profilePath)
)

internal fun GenreDto.toEntity(): GenreEntity = GenreEntity(
    id = this.id,
    name = this.name
)

internal fun ConfigurationDto.toEntity(): ConfigurationEntity = ConfigurationEntity(
    imagesBaseUrl = this.imagesBaseUrl,
    posterSizes = this.posterSizes,
    backdropSizes = this.backdropSizes,
    profileSizes = this.profileSizes
)

private fun getImageUrl(posterPath: String?): String {
    if (posterPath.isNullOrBlank()) return ""
    return "${NetworkModule.configApi.imagesBaseUrl}w342$posterPath"
}

private fun normalizeAge(isAdult: Boolean): String = if (isAdult) {
    AGE_ADULT
} else {
    AGE_CHILD
}

private fun dateToYear(value: String): String {
    if (value.isBlank()) return UNKNOWN_YEAR

    val sourceFormat = SimpleDateFormat(SOURCE_DATE_PATTERN, Locale.getDefault()).apply {
        isLenient = false
    }
    val targetFormat = SimpleDateFormat(TARGET_YEAR_PATTERN, Locale.getDefault())

    val parsedDate = try {
        sourceFormat.parse(value)
    } catch (exception: ParseException) {
        null
    }

    return parsedDate?.let(targetFormat::format) ?: UNKNOWN_YEAR
}

private fun filterGenres(genres: List<Int>): String = NetworkModule.allGenres.filter {
    genres.contains(it.id)
}.joinToString(transform = Genre::name)

internal fun List<MovieVideoDto>.toPreferredTrailerUrl(): String {
    val preferred = this.firstOrNull { video ->
        video.site.equals(YOUTUBE, ignoreCase = true) &&
            video.type.equals(TYPE_TRAILER, ignoreCase = true) &&
            video.official
    } ?: this.firstOrNull { video ->
        video.site.equals(YOUTUBE, ignoreCase = true) &&
            video.type.equals(TYPE_TRAILER, ignoreCase = true)
    } ?: this.firstOrNull { video ->
        video.site.equals(YOUTUBE, ignoreCase = true)
    }

    return preferred?.let { video ->
        "https://www.youtube.com/watch?v=${video.key}"
    } ?: ""
}

private const val AGE_ADULT = "18+"
private const val AGE_CHILD = "13+"
private const val SOURCE_DATE_PATTERN = "yyyy-MM-dd"
private const val TARGET_YEAR_PATTERN = "yyyy"
private const val YOUTUBE = "YouTube"
private const val TYPE_TRAILER = "Trailer"
internal const val UNKNOWN_YEAR = ""
