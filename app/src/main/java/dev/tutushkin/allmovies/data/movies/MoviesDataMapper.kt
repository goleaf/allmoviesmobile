package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.movies.local.*
import dev.tutushkin.allmovies.data.movies.remote.*
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

internal data class CertificationValue(
    val code: String,
    val label: String
) {
    companion object {
        val EMPTY = CertificationValue(code = "", label = "")
    }
}

internal fun MovieListDto.toEntity(
    imageSizeSelector: ImageSizeSelector,
    certification: CertificationValue = fallbackCertification(this.adult)
): MovieListEntity = MovieListEntity(
    id = this.id,
    title = this.title,
    poster = getImageUrl(this.posterPath, imageSizeSelector),
    ratings = this.voteAverage,
    numberOfRatings = this.voteCount,
    certificationLabel = certification.label,
    certificationCode = certification.code,
    year = dateToYear(this.releaseDate),
    genres = filterGenres(this.genreIds),
    isFavorite = false,
)

internal fun MovieDetailsResponse.toEntity(
    imageSizeSelector: ImageSizeSelector,
    certification: CertificationValue = fallbackCertification(this.adult)
): MovieDetailsEntity = MovieDetailsEntity(
    id = this.id,
    title = this.title,
    overview = this.overview,
    poster = getImageUrl(this.posterPath, imageSizeSelector),
    backdrop = getImageUrl(this.backdropPath, imageSizeSelector),
    ratings = this.voteAverage,
    numberOfRatings = this.voteCount,
    certificationLabel = certification.label,
    certificationCode = certification.code,
    year = dateToYear(this.releaseDate),
    runtime = this.runtime,
    genres = this.genres.joinToString { it.name },
    imdbId = this.imdbId.orEmpty(),
    isFavorite = false,
)

internal fun MovieActorDto.toEntity(imageSizeSelector: ImageSizeSelector): ActorEntity = ActorEntity(
    id = this.id,
    name = this.name,
    photo = getImageUrl(this.profilePath, imageSizeSelector)
)

internal fun ActorDetailsResponse.toEntity(
    knownFor: List<String>,
    imageSizeSelector: ImageSizeSelector
): ActorDetailsEntity = ActorDetailsEntity(
    id = this.id,
    name = this.name,
    biography = this.biography.orEmpty(),
    birthday = this.birthday,
    deathday = this.deathday,
    birthplace = this.placeOfBirth,
    profileImage = getImageUrl(this.profilePath, imageSizeSelector).ifBlank { null },
    knownForDepartment = this.knownForDepartment,
    alsoKnownAs = this.alsoKnownAs ?: emptyList(),
    imdbId = this.imdbId,
    homepage = this.homepage,
    popularity = this.popularity ?: 0.0,
    knownFor = knownFor,
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

private fun getImageUrl(
    posterPath: String?,
    imageSizeSelector: ImageSizeSelector
): String {
    if (posterPath.isNullOrBlank()) return ""
    return imageSizeSelector.buildPosterUrl(posterPath)
}

internal fun fallbackCertification(isAdult: Boolean): CertificationValue =
    if (isAdult) {
        CertificationValue(code = FALLBACK_ADULT_CODE, label = FALLBACK_ADULT_LABEL)
    } else {
        CertificationValue(code = FALLBACK_GENERAL_CODE, label = FALLBACK_GENERAL_LABEL)
    }

private fun List<String>.preferredSize(default: String): String =
    firstOrNull { it != ORIGINAL_SIZE } ?: firstOrNull() ?: default

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

internal fun ActorMovieCreditsResponse.toKnownForStrings(): List<String> {
    val prioritized = if (this.cast.isNotEmpty()) {
        this.cast
    } else {
        this.crew
    }

    return prioritized
        .sortedWith(
            compareByDescending<ActorMovieCreditDto> { it.popularity ?: 0.0 }
                .thenByDescending { it.releaseDate.orEmpty() }
        )
        .mapNotNull { credit ->
            val title = credit.title?.takeIf { it.isNotBlank() }
                ?: credit.name?.takeIf { it.isNotBlank() }
                ?: credit.originalTitle?.takeIf { it.isNotBlank() }
                ?: credit.originalName?.takeIf { it.isNotBlank() }
                ?: return@mapNotNull null

            val year = credit.releaseDate
                ?.takeIf { it.isNotBlank() }
                ?.let(::dateToYear)
                ?.takeIf { it.isNotBlank() && it != UNKNOWN_YEAR }

            val role = credit.character?.takeIf { it.isNotBlank() }
                ?: credit.job?.takeIf { it.isNotBlank() }

            buildString {
                append(title)
                if (!year.isNullOrBlank()) {
                    append(" (")
                    append(year)
                    append(')')
                }
                if (!role.isNullOrBlank()) {
                    append(" as ")
                    append(role)
                }
            }
        }
        .filter { it.isNotBlank() }
        .take(KNOWN_FOR_LIMIT)
}

private fun filterGenres(genres: List<Int>): String = emptyList<Genre>().filter {
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

private const val FALLBACK_ADULT_CODE = "ADULT"
private const val FALLBACK_GENERAL_CODE = "GENERAL"
private const val FALLBACK_ADULT_LABEL = "18+"
private const val FALLBACK_GENERAL_LABEL = "13+"
private const val DEFAULT_POSTER_SIZE = "w342"
private const val DEFAULT_BACKDROP_SIZE = "w780"
private const val DEFAULT_PROFILE_SIZE = "w185"
private const val ORIGINAL_SIZE = "original"
private const val AGE_ADULT = "18+"
private const val AGE_CHILD = "13+"
private const val SOURCE_DATE_PATTERN = "yyyy-MM-dd"
private const val TARGET_YEAR_PATTERN = "yyyy"
private const val YOUTUBE = "YouTube"
private const val TYPE_TRAILER = "Trailer"
internal const val UNKNOWN_YEAR = ""
private const val KNOWN_FOR_LIMIT = 8
