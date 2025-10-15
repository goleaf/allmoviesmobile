package dev.tutushkin.allmovies.data.movies.local

class MoviesLocalDataSourceImpl(
    private val moviesDao: MoviesDao,
    private val movieDetailsDao: MovieDetailsDao,
    private val actorsDao: ActorsDao,
    private val actorDetailsDao: ActorDetailsDao,
    private val configurationDao: ConfigurationDao,
    private val genresDao: GenresDao
) : MoviesLocalDataSource {

    override suspend fun getConfiguration(): ConfigurationEntity? =
        configurationDao.get()

    override suspend fun setConfiguration(configuration: ConfigurationEntity) {
        configurationDao.insert(configuration)
    }

    override suspend fun clearConfiguration() {
        configurationDao.delete()
    }

    override suspend fun getGenres(): List<GenreEntity> =
        genresDao.getAll()

    override suspend fun setGenres(genres: List<GenreEntity>) {
        genresDao.insertAll(genres)
    }

    override suspend fun clearGenres() {
        genresDao.deleteAll()
    }

    override suspend fun getNowPlaying(): List<MovieListEntity> =
        moviesDao.getNowPlaying()

    override suspend fun setNowPlaying(movies: List<MovieListEntity>) {
        moviesDao.insertAll(movies)
    }

    override suspend fun clearNowPlaying() {
        moviesDao.clear()
    }

    override suspend fun getMovieDetails(id: Int): MovieDetailsEntity? =
        movieDetailsDao.getMovieDetails(id)

    override suspend fun setMovieDetails(movie: MovieDetailsEntity): Long =
        movieDetailsDao.insert(movie)

    override suspend fun getFavoriteMovieDetails(): List<MovieDetailsEntity> =
        movieDetailsDao.getFavorites()

    override suspend fun getAllMovieDetails(): List<MovieDetailsEntity> =
        movieDetailsDao.getAll()

    override suspend fun clearMovieDetails() {
        movieDetailsDao.clear()
    }

    override suspend fun getActors(actorsId: List<Int>): List<ActorEntity> =
        actorsDao.getActors(actorsId)

    override suspend fun setActors(actors: List<ActorEntity>) {
        actorsDao.insertAll(actors)
    }

    override suspend fun setActorsLoaded(movieId: Int) {
        movieDetailsDao.setActorsLoaded(movieId)
    }

    override suspend fun clearActors() {
        actorsDao.deleteAll()
    }

    override suspend fun getActorDetails(actorId: Int): ActorDetailsEntity? =
        actorDetailsDao.getActorDetails(actorId)

    override suspend fun setActorDetails(actorDetails: ActorDetailsEntity) {
        actorDetailsDao.insert(actorDetails)
    }

    override suspend fun clearActorDetails() {
        actorDetailsDao.clear()
    }

    override suspend fun setMovie(movie: MovieListEntity) {
        moviesDao.insert(movie)
    }

    override suspend fun getMovie(movieId: Int): MovieListEntity? =
        moviesDao.getMovie(movieId)

    override suspend fun getFavoriteMovies(): List<MovieListEntity> =
        moviesDao.getFavorites()

    override suspend fun getFavoriteMovieIds(): Set<Int> {
        val summaryFavorites = moviesDao.getFavorites().map { it.id }
        val detailsFavorites = movieDetailsDao.getFavorites().map { it.id }
        return (summaryFavorites + detailsFavorites).toSet()
    }

    override suspend fun setFavorite(movieId: Int, isFavorite: Boolean) {
        moviesDao.updateFavorite(movieId, isFavorite)
        movieDetailsDao.updateFavorite(movieId, isFavorite)
    }
}