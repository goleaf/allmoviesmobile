package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.movies.local.DraftMovieEntity
import dev.tutushkin.allmovies.domain.movies.models.DraftMovie

internal fun DraftMovieEntity.toModel(): DraftMovie = DraftMovie(
    id = id,
    title = title,
    titleOrder = titleOrder,
    akaTitles = akaTitles,
    durationMinutes = durationMinutes,
    formats = formats,
    mpaaRating = mpaaRating,
    cast = cast,
    crew = crew,
    trailerUrl = trailerUrl,
    releaseDate = releaseDate,
    personalNotes = personalNotes,
    imdbId = imdbId,
    coverUri = coverUri,
    createdAt = createdAt,
    updatedAt = updatedAt
)

internal fun DraftMovie.toEntity(timestamp: Long = System.currentTimeMillis()): DraftMovieEntity =
    DraftMovieEntity(
        id = id,
        title = title,
        titleOrder = titleOrder,
        akaTitles = akaTitles,
        durationMinutes = durationMinutes,
        formats = formats,
        mpaaRating = mpaaRating,
        cast = cast,
        crew = crew,
        trailerUrl = trailerUrl,
        releaseDate = releaseDate,
        personalNotes = personalNotes,
        imdbId = imdbId,
        coverUri = coverUri,
        createdAt = if (id == 0L) timestamp else createdAt,
        updatedAt = timestamp
    )
