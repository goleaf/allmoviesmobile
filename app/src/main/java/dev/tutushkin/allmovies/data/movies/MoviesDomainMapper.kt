package dev.tutushkin.allmovies.data.movies

import dev.tutushkin.allmovies.data.movies.local.ActorEntity
import dev.tutushkin.allmovies.data.movies.local.CategoryEntity
import dev.tutushkin.allmovies.data.movies.local.ConfigurationEntity
import dev.tutushkin.allmovies.data.movies.local.FormatEntity
import dev.tutushkin.allmovies.data.movies.local.GenreEntity
import dev.tutushkin.allmovies.data.movies.local.LoanRecordEntity
import dev.tutushkin.allmovies.data.movies.local.MovieDetailsEntity
import dev.tutushkin.allmovies.data.movies.local.MovieListEntity
import dev.tutushkin.allmovies.data.movies.local.PersonalNoteEntity
import dev.tutushkin.allmovies.data.movies.local.UserMovieEntity
import dev.tutushkin.allmovies.domain.movies.models.Actor
import dev.tutushkin.allmovies.domain.movies.models.Category
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Format
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.LoanRecord
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.domain.movies.models.PersonalNote

internal fun MovieListEntity.toModel(
    userMovie: UserMovieEntity?,
    personalNote: PersonalNoteEntity?,
    format: FormatEntity?,
    category: CategoryEntity?
): MovieList = MovieList(
    id = this.id,
    title = this.title,
    poster = this.poster,
    ratings = this.ratings,
    numberOfRatings = this.numberOfRatings,
    minimumAge = this.minimumAge,
    year = this.year,
    genres = this.genres,
    isFavorite = userMovie?.isFavorite ?: false,
    isWatched = userMovie?.isWatched ?: false,
    isInWatchlist = userMovie?.isInWatchlist ?: false,
    personalNote = personalNote?.toModel(),
    format = format?.toModel(),
    category = category?.toModel()
)

internal fun MovieDetailsEntity.toModel(
    actors: List<Actor>,
    userMovie: UserMovieEntity?,
    personalNote: PersonalNoteEntity?,
    format: FormatEntity?,
    category: CategoryEntity?,
    loanRecords: List<LoanRecordEntity>
): MovieDetails = MovieDetails(
    id = this.id,
    title = this.title,
    overview = this.overview,
    backdrop = this.backdrop,
    ratings = this.ratings,
    numberOfRatings = this.numberOfRatings,
    minimumAge = this.minimumAge,
    year = this.year,
    runtime = this.runtime,
    genres = this.genres,
    actors = actors,
    isFavorite = userMovie?.isFavorite ?: false,
    isWatched = userMovie?.isWatched ?: false,
    isInWatchlist = userMovie?.isInWatchlist ?: false,
    personalNote = personalNote?.toModel(),
    format = format?.toModel(),
    category = category?.toModel(),
    loanHistory = loanRecords.map { it.toModel() }
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

internal fun PersonalNoteEntity.toModel(): PersonalNote = PersonalNote(
    movieId = movieId,
    note = note,
    updatedAt = updatedAt
)

internal fun FormatEntity.toModel(): Format = Format(
    id = id,
    name = name
)

internal fun CategoryEntity.toModel(): Category = Category(
    id = id,
    name = name
)

internal fun LoanRecordEntity.toModel(): LoanRecord = LoanRecord(
    id = id,
    movieId = movieId,
    borrowerName = borrowerName,
    loanDate = loanDate,
    returnDate = returnDate
)