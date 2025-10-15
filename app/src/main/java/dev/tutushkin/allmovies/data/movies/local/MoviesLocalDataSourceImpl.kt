package dev.tutushkin.allmovies.data.movies.local

class MoviesLocalDataSourceImpl(
    private val moviesDao: MoviesDao,
    private val movieDetailsDao: MovieDetailsDao,
    private val actorsDao: ActorsDao,
    private val configurationDao: ConfigurationDao,
    private val genresDao: GenresDao,
    private val draftMovieDao: DraftMovieDao
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

    override suspend fun upsertDraftMovie(movie: DraftMovieEntity): Long {
        return if (movie.id == 0L) {
            draftMovieDao.insert(movie)
        } else {
            draftMovieDao.update(movie)
            movie.id
        }
    }

    override suspend fun updateDraftMovie(movie: DraftMovieEntity) {
        draftMovieDao.update(movie)
    }

    override suspend fun getDraftMovie(id: Long): DraftMovieEntity? =
        draftMovieDao.getById(id)

    override suspend fun getDraftMovies(): List<DraftMovieEntity> =
        draftMovieDao.getAll()

    override suspend fun deleteDraftMovie(id: Long) {
        draftMovieDao.delete(id)
    }

    override suspend fun clearDraftMovies() {
        draftMovieDao.clear()
    }
}