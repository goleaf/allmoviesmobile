package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.movies.local.*
import dev.tutushkin.allmovies.domain.movies.models.*

internal fun MovieListEntity.toModel(): MovieList = MovieList(
    id = this.id,
    title = this.title,
    poster = this.poster,
    ratings = this.ratings,
    numberOfRatings = this.numberOfRatings,
    minimumAge = this.minimumAge,
    year = this.year,
    genres = this.genres
)

internal fun MovieDetailsEntity.toModel(actors: List<Actor>): MovieDetails = MovieDetails(
    id = this.id,
    title = this.title,
    overview = this.overview,
    poster = this.poster,
    backdrop = this.backdrop,
    ratings = this.ratings,
    numberOfRatings = this.numberOfRatings,
    minimumAge = this.minimumAge,
    year = this.year,
    runtime = this.runtime,
    genres = this.genres,
    imdbId = this.imdbId,
    trailerUrl = this.trailerUrl,
    loanedTo = this.loanedTo,
    loanedSince = this.loanedSince,
    loanDue = this.loanDue,
    loanStatus = this.loanStatus,
    loanNotes = this.loanNotes,
    notes = this.notes,
    actors = actors
)

internal fun ActorEntity.toModel(): Actor = Actor(
    id = this.id,
    name = this.name,
    photo = this.photo
)

internal fun GenreEntity.toModel(): Genre = Genre(
    id = this.id,
    name = this.name
)

internal fun ConfigurationEntity.toModel(): Configuration = Configuration(
    imagesBaseUrl = this.imagesBaseUrl,
    posterSizes = this.posterSizes,
    backdropSizes = this.backdropSizes,
    profileSizes = this.profileSizes
)