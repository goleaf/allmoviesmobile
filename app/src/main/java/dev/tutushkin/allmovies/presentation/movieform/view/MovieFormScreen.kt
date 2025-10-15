package dev.tutushkin.allmovies.presentation.movieform.view

import android.widget.Toast
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import com.bumptech.glide.Glide
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.databinding.LayoutMovieFormBinding
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel.MovieFormEffect
import dev.tutushkin.allmovies.presentation.movieform.viewmodel.MovieFormViewModel.MovieFormField
import dev.tutushkin.allmovies.utils.Event

class MovieFormScreen(
    private val fragment: Fragment,
    private val binding: LayoutMovieFormBinding,
    private val viewModel: MovieFormViewModel,
    private val pickCover: () -> Unit
) {

    private var updatingUi = false

    fun initialize() {
        setupListeners()
        observeViewModel()
    }

    private fun setupListeners() = with(binding) {
        movieFormTitle.doAfterTextChanged { if (!updatingUi) viewModel.onTitleChanged(it?.toString().orEmpty()) }
        movieFormTitleOrder.doAfterTextChanged { if (!updatingUi) viewModel.onTitleOrderChanged(it?.toString().orEmpty()) }
        movieFormAka.doAfterTextChanged { if (!updatingUi) viewModel.onAkaChanged(it?.toString().orEmpty()) }
        movieFormDuration.doAfterTextChanged { if (!updatingUi) viewModel.onDurationChanged(it?.toString().orEmpty()) }
        movieFormReleaseDate.doAfterTextChanged { if (!updatingUi) viewModel.onReleaseDateChanged(it?.toString().orEmpty()) }
        movieFormFormats.doAfterTextChanged { if (!updatingUi) viewModel.onFormatsChanged(it?.toString().orEmpty()) }
        movieFormMpaa.doAfterTextChanged { if (!updatingUi) viewModel.onMpaaChanged(it?.toString().orEmpty()) }
        movieFormCast.doAfterTextChanged { if (!updatingUi) viewModel.onCastChanged(it?.toString().orEmpty()) }
        movieFormCrew.doAfterTextChanged { if (!updatingUi) viewModel.onCrewChanged(it?.toString().orEmpty()) }
        movieFormTrailer.doAfterTextChanged { if (!updatingUi) viewModel.onTrailerChanged(it?.toString().orEmpty()) }
        movieFormPersonalNotes.doAfterTextChanged { if (!updatingUi) viewModel.onPersonalNotesChanged(it?.toString().orEmpty()) }
        movieFormImdb.doAfterTextChanged { if (!updatingUi) viewModel.onImdbChanged(it?.toString().orEmpty()) }

        movieFormPickCover.setOnClickListener { pickCover.invoke() }
        movieFormRemoveCover.setOnClickListener { viewModel.onRemoveCover() }
        movieFormSearchTrailer.setOnClickListener { viewModel.onSearchTrailer() }
        movieFormDownloadImdb.setOnClickListener { viewModel.onDownloadFromImdb() }
        movieFormSave.setOnClickListener { viewModel.onSaveClicked(false) }
        movieFormSaveAddAnother.setOnClickListener { viewModel.onSaveClicked(true) }
    }

    private fun observeViewModel() {
        viewModel.state.observe(fragment.viewLifecycleOwner) { state ->
            updatingUi = true
            with(binding) {
                if (movieFormTitle.text?.toString() != state.title) {
                    movieFormTitle.setText(state.title)
                }
                if (movieFormTitleOrder.text?.toString() != state.titleOrder) {
                    movieFormTitleOrder.setText(state.titleOrder)
                }
                if (movieFormAka.text?.toString() != state.akaTitles) {
                    movieFormAka.setText(state.akaTitles)
                }
                if (movieFormDuration.text?.toString() != state.duration) {
                    movieFormDuration.setText(state.duration)
                }
                if (movieFormReleaseDate.text?.toString() != state.releaseDate) {
                    movieFormReleaseDate.setText(state.releaseDate)
                }
                if (movieFormFormats.text?.toString() != state.formats) {
                    movieFormFormats.setText(state.formats)
                }
                if (movieFormMpaa.text?.toString() != state.mpaa) {
                    movieFormMpaa.setText(state.mpaa)
                }
                if (movieFormCast.text?.toString() != state.cast) {
                    movieFormCast.setText(state.cast)
                }
                if (movieFormCrew.text?.toString() != state.crew) {
                    movieFormCrew.setText(state.crew)
                }
                if (movieFormTrailer.text?.toString() != state.trailerUrl) {
                    movieFormTrailer.setText(state.trailerUrl)
                }
                if (movieFormPersonalNotes.text?.toString() != state.personalNotes) {
                    movieFormPersonalNotes.setText(state.personalNotes)
                }
                if (movieFormImdb.text?.toString() != state.imdbId) {
                    movieFormImdb.setText(state.imdbId)
                }

                movieFormTitleLayout.error = state.validationErrors[MovieFormField.TITLE]?.let(fragment::getString)
                movieFormDurationLayout.error = state.validationErrors[MovieFormField.DURATION]?.let(fragment::getString)
                movieFormReleaseDateLayout.error = state.validationErrors[MovieFormField.RELEASE_DATE]?.let(fragment::getString)
                movieFormTrailerLayout.error = state.validationErrors[MovieFormField.TRAILER]?.let(fragment::getString)

                movieFormSave.isEnabled = !state.isSaving
                movieFormSaveAddAnother.isEnabled = !state.isSaving

                if (state.coverUri != null) {
                    Glide.with(fragment.requireContext())
                        .load(state.coverUri)
                        .placeholder(R.drawable.ic_launcher_background)
                        .into(movieFormCover)
                } else {
                    Glide.with(fragment.requireContext())
                        .load(R.drawable.ic_launcher_foreground)
                        .into(movieFormCover)
                }
            }
            updatingUi = false
        }

        viewModel.events.observe(fragment.viewLifecycleOwner) { event ->
            handleEvent(event)
        }
    }

    private fun handleEvent(event: Event<MovieFormEffect>) {
        when (val effect = event.getContentIfNotHandled()) {
            MovieFormEffect.Saved -> {
                Toast.makeText(fragment.requireContext(), R.string.movie_form_saved_message, Toast.LENGTH_SHORT).show()
            }
            MovieFormEffect.SavedAddAnother -> {
                Toast.makeText(fragment.requireContext(), R.string.movie_form_saved_add_another, Toast.LENGTH_SHORT).show()
            }
            MovieFormEffect.CoverRemoved -> {
                Toast.makeText(fragment.requireContext(), R.string.movie_form_cover_removed, Toast.LENGTH_SHORT).show()
            }
            is MovieFormEffect.ShowMessageRes -> {
                Toast.makeText(fragment.requireContext(), effect.messageRes, Toast.LENGTH_SHORT).show()
            }
            is MovieFormEffect.Error -> {
                if (effect.message.isNotBlank()) {
                    Toast.makeText(fragment.requireContext(), effect.message, Toast.LENGTH_SHORT).show()
                }
            }
            null -> Unit
        }
    }
}
