package dev.tutushkin.allmovies.presentation

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.findNavController
import androidx.recyclerview.widget.RecyclerView
import androidx.test.core.app.ActivityScenario
import androidx.test.core.app.ApplicationProvider
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.Espresso.openActionBarOverflowOrOptionsMenu
import androidx.test.espresso.Espresso.pressBack
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.contrib.RecyclerViewActions
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.MediumTest
import androidx.test.platform.app.InstrumentationRegistry
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.Actor
import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.domain.movies.models.Configuration
import dev.tutushkin.allmovies.domain.movies.models.Genre
import dev.tutushkin.allmovies.domain.movies.models.MovieDetails
import dev.tutushkin.allmovies.domain.movies.models.MovieList
import dev.tutushkin.allmovies.presentation.actors.view.ActorDetailsFragment
import dev.tutushkin.allmovies.presentation.actors.viewmodel.ActorDetailsViewModel
import dev.tutushkin.allmovies.presentation.analytics.SharedLinkAnalytics
import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier
import dev.tutushkin.allmovies.presentation.favorites.view.FavoritesFragment
import dev.tutushkin.allmovies.presentation.favorites.viewmodel.FavoritesViewModel
import dev.tutushkin.allmovies.presentation.moviedetails.view.MovieDetailsFragment
import dev.tutushkin.allmovies.presentation.moviedetails.viewmodel.MovieDetailsViewModel
import dev.tutushkin.allmovies.presentation.movies.view.MoviesFragment
import dev.tutushkin.allmovies.presentation.movies.viewmodel.MoviesViewModel
import dev.tutushkin.allmovies.presentation.navigation.ARG_ACTOR_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_ID
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SHARED
import dev.tutushkin.allmovies.presentation.navigation.ARG_MOVIE_SLUG
import kotlinx.coroutines.flow.MutableSharedFlow
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
@MediumTest
class MainActivityNavigationTest {

    private lateinit var repository: FakeMoviesRepository
    private lateinit var favoritesNotifier: FakeFavoritesUpdateNotifier
    private lateinit var moviesViewModel: MoviesViewModel
    private lateinit var favoritesViewModel: FavoritesViewModel
    private lateinit var languagePreferences: LanguagePreferences

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        languagePreferences = LanguagePreferences(context)
        languagePreferences.setSelectedLanguage("en")

        val movie = MovieList(
            id = 1,
            title = "Test Movie",
            poster = "",
            ratings = 4.5f,
            numberOfRatings = 120,
            minimumAge = "13+",
            year = "2023",
            genres = "Drama",
            isFavorite = true
        )
        val actor = Actor(id = 10, name = "Test Actor", photo = null)
        val movieDetails = MovieDetails(
            id = 1,
            title = "Test Movie",
            overview = "Overview",
            poster = "",
            backdrop = "",
            ratings = 4.5f,
            numberOfRatings = 120,
            minimumAge = "13+",
            year = "2023",
            runtime = 100,
            genres = "Drama",
            imdbId = "",
            trailerUrl = "",
            loanedTo = "",
            loanedSince = "",
            loanDue = "",
            loanStatus = "",
            loanNotes = "",
            notes = "",
            actors = listOf(actor),
            isFavorite = true
        )
        val actorDetails = ActorDetails(
            id = 10,
            name = "Test Actor",
            biography = "Bio",
            birthday = null,
            deathday = null,
            birthplace = "Somewhere",
            profileImage = null,
            knownForDepartment = "Acting",
            alsoKnownAs = listOf("Alias"),
            imdbId = null,
            homepage = null,
            popularity = 10.0,
            knownFor = listOf("Test Movie")
        )

        repository = FakeMoviesRepository(
            initialMovies = mutableListOf(movie),
            initialMovieDetails = mutableMapOf(movie.id to movieDetails),
            initialActorDetails = mutableMapOf(actor.id to actorDetails)
        )
        favoritesNotifier = FakeFavoritesUpdateNotifier()
        moviesViewModel = MoviesViewModel(repository, languagePreferences, favoritesNotifier)
        favoritesViewModel = FavoritesViewModel(repository, favoritesNotifier)

        MoviesFragment.defaultViewModelFactoryOverride = SingleViewModelFactory(moviesViewModel)
        FavoritesFragment.defaultMoviesViewModelFactoryOverride = SingleViewModelFactory(moviesViewModel)
        FavoritesFragment.defaultFavoritesViewModelFactoryOverride = SingleViewModelFactory(favoritesViewModel)
        MovieDetailsFragment.defaultMoviesViewModelFactoryOverride = SingleViewModelFactory(moviesViewModel)
        MovieDetailsFragment.defaultMovieDetailsViewModelFactoryProvider = { fragment ->
            val args = fragment.requireArguments()
            val movieId = args.getInt(ARG_MOVIE_ID)
            val slug = args.getString(ARG_MOVIE_SLUG)
            val shared = args.getBoolean(ARG_MOVIE_SHARED, false)
            val analytics = object : SharedLinkAnalytics {
                override fun logSharedLinkOpened(movieId: Int, slug: String?) {
                    // No-op for tests
                }
            }
            LambdaViewModelFactory {
                MovieDetailsViewModel(
                    repository,
                    movieId,
                    slug,
                    shared,
                    analytics,
                    languagePreferences.getSelectedLanguage(),
                    moviesViewModel
                )
            }
        }
        ActorDetailsFragment.defaultViewModelFactoryProvider = { fragment ->
            val actorId = fragment.requireArguments().getInt(ARG_ACTOR_ID)
            LambdaViewModelFactory {
                ActorDetailsViewModel(
                    repository,
                    actorId,
                    languagePreferences.getSelectedLanguage()
                )
            }
        }
    }

    @After
    fun tearDown() {
        MoviesFragment.defaultViewModelFactoryOverride = null
        FavoritesFragment.defaultMoviesViewModelFactoryOverride = null
        FavoritesFragment.defaultFavoritesViewModelFactoryOverride = null
        MovieDetailsFragment.defaultMoviesViewModelFactoryOverride = null
        MovieDetailsFragment.defaultMovieDetailsViewModelFactoryProvider = null
        ActorDetailsFragment.defaultViewModelFactoryProvider = null
    }

    @Test
    fun favoritesAndActorFlowsNavigateToExpectedDestinations() {
        val scenario = ActivityScenario.launch(MainActivity::class.java)

        InstrumentationRegistry.getInstrumentation().waitForIdleSync()

        val context = ApplicationProvider.getApplicationContext<Context>()
        openActionBarOverflowOrOptionsMenu(context)
        onView(withText(R.string.menu_favorites)).perform(click())

        scenario.onActivity { activity ->
            val destination = activity.findNavController(R.id.main_nav_host).currentDestination?.id
            assertEquals(R.id.favoritesFragment, destination)
        }

        pressBack()

        onView(withId(R.id.movies_list_recycler)).perform(
            RecyclerViewActions.actionOnItemAtPosition<RecyclerView.ViewHolder>(0, click())
        )

        InstrumentationRegistry.getInstrumentation().waitForIdleSync()

        onView(withId(R.id.movie_details_actors_recycler)).perform(
            RecyclerViewActions.actionOnItemAtPosition<RecyclerView.ViewHolder>(0, click())
        )

        scenario.onActivity { activity ->
            val destination = activity.findNavController(R.id.main_nav_host).currentDestination?.id
            assertEquals(R.id.actorDetailsFragment, destination)
        }

        scenario.close()
    }

    private class SingleViewModelFactory<T : ViewModel>(
        private val viewModel: T
    ) : ViewModelProvider.Factory {
        override fun <R : ViewModel> create(modelClass: Class<R>): R {
            if (modelClass.isAssignableFrom(viewModel::class.java)) {
                @Suppress("UNCHECKED_CAST")
                return viewModel as R
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${'$'}modelClass")
        }
    }

    private class LambdaViewModelFactory(
        private val creator: () -> ViewModel
    ) : ViewModelProvider.Factory {
        override fun <R : ViewModel> create(modelClass: Class<R>): R {
            val viewModel = creator()
            if (modelClass.isAssignableFrom(viewModel::class.java)) {
                @Suppress("UNCHECKED_CAST")
                return viewModel as R
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${'$'}modelClass")
        }
    }

    private class FakeFavoritesUpdateNotifier : FavoritesUpdateNotifier {
        override val updates = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

        override fun notifyFavoritesChanged() {
            updates.tryEmit(Unit)
        }
    }

    private class FakeMoviesRepository(
        private val initialMovies: MutableList<MovieList>,
        private val initialMovieDetails: MutableMap<Int, MovieDetails>,
        private val initialActorDetails: MutableMap<Int, ActorDetails>
    ) : MoviesRepository {

        private val movies = initialMovies
        private val movieDetails = initialMovieDetails
        private val actorDetails = initialActorDetails

        override suspend fun getConfiguration(apiKey: String, language: String): Result<Configuration> {
            return Result.success(Configuration())
        }

        override suspend fun getGenres(apiKey: String, language: String): Result<List<Genre>> {
            return Result.success(emptyList())
        }

        override suspend fun getNowPlaying(apiKey: String, language: String): Result<List<MovieList>> {
            return Result.success(movies.toList())
        }

        override suspend fun searchMovies(
            apiKey: String,
            language: String,
            query: String,
            includeAdult: Boolean
        ): Result<List<MovieList>> {
            return Result.success(emptyList())
        }

        override suspend fun getMovieDetails(
            movieId: Int,
            apiKey: String,
            language: String,
            ensureCached: Boolean
        ): Result<MovieDetails> {
            return movieDetails[movieId]?.let { Result.success(it) }
                ?: Result.failure(IllegalArgumentException("Missing movie details"))
        }

        override suspend fun getActorDetails(
            actorId: Int,
            apiKey: String,
            language: String
        ): Result<ActorDetails> {
            return actorDetails[actorId]?.let { Result.success(it) }
                ?: Result.failure(IllegalArgumentException("Missing actor details"))
        }

        override suspend fun setFavorite(movieId: Int, isFavorite: Boolean): Result<Unit> {
            val index = movies.indexOfFirst { it.id == movieId }
            if (index >= 0) {
                movies[index] = movies[index].copy(isFavorite = isFavorite)
            }
            movieDetails[movieId]?.let { details ->
                movieDetails[movieId] = details.copy(isFavorite = isFavorite)
            }
            return Result.success(Unit)
        }

        override suspend fun getFavorites(): Result<List<MovieList>> {
            return Result.success(movies.filter { it.isFavorite })
        }

        override suspend fun clearAll() {
            // No-op for tests
        }

        override suspend fun refreshLibrary(
            apiKey: String,
            language: String,
            onProgress: (current: Int, total: Int, title: String) -> Unit
        ): Result<Unit> {
            return Result.success(Unit)
        }
    }
}
