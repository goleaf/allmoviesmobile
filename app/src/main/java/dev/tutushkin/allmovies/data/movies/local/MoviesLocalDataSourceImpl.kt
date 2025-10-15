package dev.tutushkin.allmovies.data.movies.local

class MoviesLocalDataSourceImpl(
    private val moviesDao: MoviesDao,
    private val movieDetailsDao: MovieDetailsDao,
    private val actorsDao: ActorsDao,
    private val configurationDao: ConfigurationDao,
    private val genresDao: GenresDao,
    private val userMoviesDao: UserMoviesDao,
    private val personalNotesDao: PersonalNotesDao,
    private val formatsDao: FormatsDao,
    private val categoriesDao: CategoriesDao,
    private val loanRecordsDao: LoanRecordsDao
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

    override suspend fun getUserMovies(movieIds: List<Int>): List<UserMovieEntity> =
        if (movieIds.isEmpty()) {
            emptyList()
        } else {
            userMoviesDao.get(movieIds)
        }

    override suspend fun getUserMovie(movieId: Int): UserMovieEntity? =
        userMoviesDao.get(movieId)

    override suspend fun upsertUserMovie(userMovieEntity: UserMovieEntity) {
        userMoviesDao.upsert(userMovieEntity)
    }

    override suspend fun deleteUserMovie(movieId: Int) {
        userMoviesDao.delete(movieId)
    }

    override suspend fun getPersonalNotes(movieIds: List<Int>): List<PersonalNoteEntity> =
        if (movieIds.isEmpty()) {
            emptyList()
        } else {
            personalNotesDao.get(movieIds)
        }

    override suspend fun getPersonalNote(movieId: Int): PersonalNoteEntity? =
        personalNotesDao.get(movieId)

    override suspend fun upsertPersonalNote(personalNoteEntity: PersonalNoteEntity) {
        personalNotesDao.upsert(personalNoteEntity)
    }

    override suspend fun deletePersonalNote(movieId: Int) {
        personalNotesDao.delete(movieId)
    }

    override suspend fun getFormats(): List<FormatEntity> =
        formatsDao.getAll()

    override suspend fun getFormatById(id: Int): FormatEntity? =
        formatsDao.getById(id)

    override suspend fun insertFormat(formatEntity: FormatEntity): Long =
        formatsDao.insert(formatEntity)

    override suspend fun updateFormat(formatEntity: FormatEntity) {
        formatsDao.update(formatEntity)
    }

    override suspend fun deleteFormat(formatEntity: FormatEntity) {
        formatsDao.delete(formatEntity)
    }

    override suspend fun getCategories(): List<CategoryEntity> =
        categoriesDao.getAll()

    override suspend fun getCategoryById(id: Int): CategoryEntity? =
        categoriesDao.getById(id)

    override suspend fun insertCategory(categoryEntity: CategoryEntity): Long =
        categoriesDao.insert(categoryEntity)

    override suspend fun updateCategory(categoryEntity: CategoryEntity) {
        categoriesDao.update(categoryEntity)
    }

    override suspend fun deleteCategory(categoryEntity: CategoryEntity) {
        categoriesDao.delete(categoryEntity)
    }

    override suspend fun getLoanHistory(movieId: Int): List<LoanRecordEntity> =
        loanRecordsDao.getByMovie(movieId)

    override suspend fun insertLoanRecord(loanRecordEntity: LoanRecordEntity): Long =
        loanRecordsDao.insert(loanRecordEntity)

    override suspend fun updateLoanRecord(loanRecordEntity: LoanRecordEntity) {
        loanRecordsDao.update(loanRecordEntity)
    }

    override suspend fun deleteLoanRecord(id: Long) {
        loanRecordsDao.delete(id)
    }
}