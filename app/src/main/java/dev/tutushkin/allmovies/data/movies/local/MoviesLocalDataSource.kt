package dev.tutushkin.allmovies.data.movies.local

interface MoviesLocalDataSource {

    suspend fun getConfiguration(): ConfigurationEntity?

    suspend fun setConfiguration(configuration: ConfigurationEntity)

    suspend fun clearConfiguration()

    suspend fun getGenres(): List<GenreEntity>

    suspend fun setGenres(genres: List<GenreEntity>)

    suspend fun clearGenres()

    suspend fun getNowPlaying(): List<MovieListEntity>

    suspend fun setNowPlaying(movies: List<MovieListEntity>)

    suspend fun clearNowPlaying()

    suspend fun getMovieDetails(id: Int): MovieDetailsEntity?

    suspend fun setMovieDetails(movie: MovieDetailsEntity): Long

    suspend fun clearMovieDetails()

    suspend fun getActors(actorsId: List<Int>): List<ActorEntity>

    suspend fun setActors(actors: List<ActorEntity>)

    suspend fun setActorsLoaded(movieId: Int)

    suspend fun clearActors()

    suspend fun getUserMovies(movieIds: List<Int>): List<UserMovieEntity>

    suspend fun getUserMovie(movieId: Int): UserMovieEntity?

    suspend fun upsertUserMovie(userMovieEntity: UserMovieEntity)

    suspend fun deleteUserMovie(movieId: Int)

    suspend fun getPersonalNotes(movieIds: List<Int>): List<PersonalNoteEntity>

    suspend fun getPersonalNote(movieId: Int): PersonalNoteEntity?

    suspend fun upsertPersonalNote(personalNoteEntity: PersonalNoteEntity)

    suspend fun deletePersonalNote(movieId: Int)

    suspend fun getFormats(): List<FormatEntity>

    suspend fun getFormatById(id: Int): FormatEntity?

    suspend fun insertFormat(formatEntity: FormatEntity): Long

    suspend fun updateFormat(formatEntity: FormatEntity)

    suspend fun deleteFormat(formatEntity: FormatEntity)

    suspend fun getCategories(): List<CategoryEntity>

    suspend fun getCategoryById(id: Int): CategoryEntity?

    suspend fun insertCategory(categoryEntity: CategoryEntity): Long

    suspend fun updateCategory(categoryEntity: CategoryEntity)

    suspend fun deleteCategory(categoryEntity: CategoryEntity)

    suspend fun getLoanHistory(movieId: Int): List<LoanRecordEntity>

    suspend fun insertLoanRecord(loanRecordEntity: LoanRecordEntity): Long

    suspend fun updateLoanRecord(loanRecordEntity: LoanRecordEntity)

    suspend fun deleteLoanRecord(id: Long)
}