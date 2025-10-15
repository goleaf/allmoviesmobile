package dev.tutushkin.allmovies.presentation.movieform.viewmodel

import android.app.Application
import android.net.Uri
import android.util.Patterns
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import dev.tutushkin.allmovies.BuildConfig
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.domain.movies.MoviesRepository
import dev.tutushkin.allmovies.domain.movies.models.DraftMovie
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel.MovieFormField.DURATION
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel.MovieFormField.RELEASE_DATE
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel.MovieFormField.TITLE
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel.MovieFormField.TRAILER
import dev.tutushkin.allmovies.utils.CoverStorage
import dev.tutushkin.allmovies.utils.Event
import dev.tutushkin.allmovies.utils.YouTubeTrailerSearcher
import kotlinx.coroutines.launch
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Locale

class MovieFormViewModel(
    application: Application,
    private val repository: MoviesRepository,
    private val youtubeSearcher: YouTubeTrailerSearcher,
    private val initialDraftId: Long?
) : AndroidViewModel(application) {

    private val _state = MutableLiveData(MovieFormViewState())
    val state: LiveData<MovieFormViewState> = _state

    private val _events = MutableLiveData<Event<MovieFormEffect>>()
    val events: LiveData<Event<MovieFormEffect>> = _events

    private var currentDraft: DraftMovie? = null

    init {
        if (initialDraftId != null) {
            viewModelScope.launch {
                repository.getDraft(initialDraftId)
                    .onSuccess { draft ->
                        draft?.let {
                            currentDraft = it
                            _state.value = MovieFormViewState.fromDraft(it)
                        }
                    }
            }
        }
    }

    fun onTitleChanged(value: String) = updateState { copy(title = value) }

    fun onTitleOrderChanged(value: String) = updateState { copy(titleOrder = value) }

    fun onAkaChanged(value: String) = updateState { copy(akaTitles = value) }

    fun onDurationChanged(value: String) = updateState { copy(duration = value) }

    fun onReleaseDateChanged(value: String) = updateState { copy(releaseDate = value) }

    fun onFormatsChanged(value: String) = updateState { copy(formats = value) }

    fun onMpaaChanged(value: String) = updateState { copy(mpaa = value) }

    fun onCastChanged(value: String) = updateState { copy(cast = value) }

    fun onCrewChanged(value: String) = updateState { copy(crew = value) }

    fun onTrailerChanged(value: String) = updateState { copy(trailerUrl = value) }

    fun onPersonalNotesChanged(value: String) = updateState { copy(personalNotes = value) }

    fun onImdbChanged(value: String) = updateState { copy(imdbId = value) }

    fun onSaveClicked(addAnother: Boolean) {
        val state = _state.value ?: return
        val validation = validate(state)
        if (validation.isNotEmpty()) {
            updateState { copy(validationErrors = validation) }
            return
        }

        viewModelScope.launch {
            updateState { copy(isSaving = true, validationErrors = emptyMap()) }
            val draft = buildDraft(state)
            val isNew = currentDraft == null || currentDraft?.id == 0L

            if (isNew) {
                repository.saveDraft(draft)
                    .onSuccess { id ->
                        currentDraft = draft.copy(id = id)
                        handlePostSave(addAnother)
                    }
                    .onFailure { throwable ->
                        _events.value = Event(MovieFormEffect.Error(throwable.localizedMessage ?: ""))
                    }
            } else {
                val existing = currentDraft!!
                repository.updateDraft(draft.copy(id = existing.id, createdAt = existing.createdAt))
                    .onSuccess {
                        currentDraft = draft.copy(id = existing.id, createdAt = existing.createdAt)
                        handlePostSave(addAnother)
                    }
                    .onFailure { throwable ->
                        _events.value = Event(MovieFormEffect.Error(throwable.localizedMessage ?: ""))
                    }
            }
            updateState { copy(isSaving = false) }
        }
    }

    private fun handlePostSave(addAnother: Boolean) {
        if (addAnother) {
            currentDraft = null
            _state.value = MovieFormViewState()
            _events.value = Event(MovieFormEffect.SavedAddAnother)
        } else {
            _events.value = Event(MovieFormEffect.Saved)
        }
    }

    fun onRemoveCover() {
        val cover = _state.value?.coverUri ?: return
        viewModelScope.launch {
            CoverStorage.removeCover(getApplication(), cover)
            currentDraft = currentDraft?.copy(coverUri = null)
            updateState { copy(coverUri = null) }
            _events.value = Event(MovieFormEffect.CoverRemoved)
        }
    }

    fun onCoverSelected(uri: Uri) {
        viewModelScope.launch {
            val current = _state.value?.coverUri
            if (current != null) {
                CoverStorage.removeCover(getApplication(), current)
            }
            val cached = CoverStorage.cacheCover(getApplication(), uri)
            currentDraft = currentDraft?.copy(coverUri = cached.toString())
            updateState { copy(coverUri = cached) }
        }
    }

    fun onSearchTrailer() {
        val current = _state.value ?: return
        val query = current.title.ifBlank { current.akaTitles }.ifBlank { return }
        viewModelScope.launch {
            youtubeSearcher.search("$query trailer")
                .onSuccess { url -> updateState { copy(trailerUrl = url) } }
                .onFailure { throwable ->
                    val message = throwable.message ?: ""
                    val effect = if (message.contains("No results", ignoreCase = true)) {
                        MovieFormEffect.ShowMessageRes(R.string.movie_form_trailer_not_found)
                    } else {
                        MovieFormEffect.ShowMessageRes(R.string.movie_form_trailer_error)
                    }
                    _events.value = Event(effect)
                }
        }
    }

    fun onDownloadFromImdb() {
        val imdbId = _state.value?.imdbId?.trim().orEmpty()
        if (imdbId.isBlank()) {
            _events.value = Event(MovieFormEffect.ShowMessageRes(R.string.movie_form_imdb_required))
            return
        }
        viewModelScope.launch {
            repository.downloadDraftFromImdb(imdbId, BuildConfig.API_KEY)
                .onSuccess { draft ->
                    currentDraft = draft
                    _state.value = MovieFormViewState.fromDraft(draft)
                }
                .onFailure {
                    _events.value = Event(MovieFormEffect.ShowMessageRes(R.string.movie_form_download_failed))
                }
        }
    }

    private fun updateState(block: MovieFormViewState.() -> MovieFormViewState) {
        _state.value = block(_state.value ?: MovieFormViewState())
    }

    private fun validate(state: MovieFormViewState): Map<MovieFormField, Int> {
        val errors = mutableMapOf<MovieFormField, Int>()
        if (state.title.isBlank()) {
            errors[TITLE] = R.string.movie_form_validation_title
        }
        if (state.duration.isNotBlank() && state.duration.toIntOrNull() == null) {
            errors[DURATION] = R.string.movie_form_validation_duration
        }
        if (state.releaseDate.isNotBlank() && !isValidDate(state.releaseDate)) {
            errors[RELEASE_DATE] = R.string.movie_form_validation_release_date
        }
        if (state.trailerUrl.isNotBlank() && !Patterns.WEB_URL.matcher(state.trailerUrl).matches()) {
            errors[TRAILER] = R.string.movie_form_validation_trailer
        }
        return errors
    }

    private fun isValidDate(value: String): Boolean {
        val format = SimpleDateFormat(DATE_PATTERN, Locale.getDefault())
        format.isLenient = false
        return try {
            format.parse(value)
            true
        } catch (exception: ParseException) {
            false
        }
    }

    private fun buildDraft(state: MovieFormViewState): DraftMovie {
        val duration = state.duration.toIntOrNull()
        val formats = state.formats.splitToList()
        val aka = state.akaTitles.splitToList()
        val cast = state.cast.splitToList()
        val crew = state.crew.splitToList()
        val cover = state.coverUri?.toString()
        val now = System.currentTimeMillis()
        val draft = currentDraft
        return DraftMovie(
            id = draft?.id ?: 0L,
            title = state.title.trim(),
            titleOrder = state.titleOrder.trim(),
            akaTitles = aka,
            durationMinutes = duration,
            formats = formats,
            mpaaRating = state.mpaa.trim(),
            cast = cast,
            crew = crew,
            trailerUrl = state.trailerUrl.trim(),
            releaseDate = state.releaseDate.trim(),
            personalNotes = state.personalNotes.trim(),
            imdbId = state.imdbId.trim().ifBlank { null },
            coverUri = cover,
            createdAt = draft?.createdAt ?: now,
            updatedAt = now
        )
    }

    private fun String.splitToList(): List<String> {
        if (isBlank()) return emptyList()
        return split(',', '\n')
            .map { it.trim() }
            .filter { it.isNotBlank() }
    }

        }

    data class MovieFormViewState(
        val title: String = "",
        val titleOrder: String = "",
        val akaTitles: String = "",
        val duration: String = "",
        val releaseDate: String = "",
        val formats: String = "",
        val mpaa: String = "",
        val cast: String = "",
        val crew: String = "",
        val trailerUrl: String = "",
        val personalNotes: String = "",
        val imdbId: String = "",
        val coverUri: Uri? = null,
        val validationErrors: Map<MovieFormField, Int> = emptyMap(),
        val isSaving: Boolean = false
    ) {
        companion object {
            fun fromDraft(draft: DraftMovie): MovieFormViewState = MovieFormViewState(
                title = draft.title,
                titleOrder = draft.titleOrder,
                akaTitles = draft.akaTitles.joinToString(separator = ", "),
                duration = draft.durationMinutes?.toString().orEmpty(),
                releaseDate = draft.releaseDate,
                formats = draft.formats.joinToString(separator = ", "),
                mpaa = draft.mpaaRating,
                cast = draft.cast.joinToString(separator = ", "),
                crew = draft.crew.joinToString(separator = ", "),
                trailerUrl = draft.trailerUrl,
                personalNotes = draft.personalNotes,
                imdbId = draft.imdbId.orEmpty(),
                coverUri = draft.coverUri?.let(Uri::parse)
            )
        }
    }

    enum class MovieFormField {
        TITLE,
        DURATION,
        RELEASE_DATE,
        TRAILER
    }

    sealed class MovieFormEffect {
        object Saved : MovieFormEffect()
        object SavedAddAnother : MovieFormEffect()
        object CoverRemoved : MovieFormEffect()
        data class ShowMessageRes(val messageRes: Int) : MovieFormEffect()
        data class Error(val message: String) : MovieFormEffect()
    }

    class Factory(
        private val application: Application,
        private val repository: MoviesRepository,
        private val youtubeSearcher: YouTubeTrailerSearcher,
        private val draftId: Long?
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MovieFormViewModel::class.java)) {
                return MovieFormViewModel(application, repository, youtubeSearcher, draftId) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }

    companion object {
        private const val DATE_PATTERN = "yyyy-MM-dd"
    }
}
