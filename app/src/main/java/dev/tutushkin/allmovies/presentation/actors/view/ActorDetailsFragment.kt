package dev.tutushkin.allmovies.presentation.actors.view

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.bumptech.glide.Glide
import com.bumptech.glide.load.MultiTransformation
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.core.db.MoviesDb
import dev.tutushkin.allmovies.data.core.network.NetworkModule
import dev.tutushkin.allmovies.data.movies.MoviesRepositoryImpl
import dev.tutushkin.allmovies.data.movies.local.MoviesLocalDataSourceImpl
import dev.tutushkin.allmovies.data.movies.remote.MoviesRemoteDataSourceImpl
import dev.tutushkin.allmovies.data.settings.LanguagePreferences
import dev.tutushkin.allmovies.databinding.FragmentActorDetailsBinding
import dev.tutushkin.allmovies.domain.movies.models.ActorDetails
import dev.tutushkin.allmovies.presentation.actors.viewmodel.ActorDetailsState
import dev.tutushkin.allmovies.presentation.actors.viewmodel.ActorDetailsViewModel
import dev.tutushkin.allmovies.presentation.actors.viewmodel.ActorDetailsViewModelFactory
import dev.tutushkin.allmovies.presentation.navigation.ARG_ACTOR_ID
import kotlinx.coroutines.Dispatchers
import kotlinx.serialization.ExperimentalSerializationApi

@OptIn(ExperimentalSerializationApi::class)
class ActorDetailsFragment : Fragment(R.layout.fragment_actor_details) {

    private var _binding: FragmentActorDetailsBinding? = null
    private val binding get() = _binding

    private val args: ActorDetailsArgs by lazy { parseArgs(arguments) }

    private val viewModel: ActorDetailsViewModel by viewModels {
        val application = requireActivity().application
        val db = MoviesDb.getDatabase(application)
        val remoteDataSource = MoviesRemoteDataSourceImpl(NetworkModule.moviesApi)
        val localDataSource = MoviesLocalDataSourceImpl(
            db.moviesDao(),
            db.movieDetails(),
            db.actorsDao(),
            db.actorDetailsDao(),
            db.configurationDao(),
            db.genresDao(),
        )
        val repository = MoviesRepositoryImpl(remoteDataSource, localDataSource, Dispatchers.IO)
        val languagePreferences = LanguagePreferences(requireContext().applicationContext)
        ActorDetailsViewModelFactory(repository, args.actorId, languagePreferences.getSelectedLanguage())
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentActorDetailsBinding.bind(view)

        binding?.actorDetailsBackText?.setOnClickListener {
            requireActivity().supportFragmentManager.popBackStack()
        }
        binding?.actorDetailsBackImage?.setOnClickListener {
            requireActivity().supportFragmentManager.popBackStack()
        }
        binding?.actorDetailsRetryButton?.setOnClickListener {
            viewModel.retry()
        }

        viewModel.actorDetails.observe(viewLifecycleOwner, ::render)
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    private fun render(state: ActorDetailsState) {
        when (state) {
            is ActorDetailsState.Loading -> showLoading()
            is ActorDetailsState.Result -> renderResult(state.details)
            is ActorDetailsState.Error -> showError(state.throwable)
        }
    }

    private fun renderResult(details: ActorDetails) {
        binding?.apply {
            actorDetailsProgress.isVisible = false
            actorDetailsErrorGroup.isVisible = false
            actorDetailsScroll.isVisible = true

            actorDetailsNameText.text = details.name

            val department = details.knownForDepartment
            actorDetailsDepartmentText.isVisible = !department.isNullOrBlank()
            actorDetailsDepartmentText.text = department ?: ""

            actorDetailsPopularityText.text =
                getString(R.string.actor_details_popularity, details.popularity)

            val biography = details.biography.takeIf { it.isNotBlank() }
                ?: getString(R.string.actor_details_biography_empty)
            actorDetailsBiographyText.text = biography

            val radius = (12 * root.resources.displayMetrics.density).toInt()
            Glide.with(root.context)
                .load(details.profileImage)
                .placeholder(R.drawable.ic_baseline_image_24)
                .error(R.drawable.ic_baseline_image_24)
                .transform(MultiTransformation(CenterCrop(), RoundedCorners(radius)))
                .into(actorDetailsPhotoImage)

            setInfo(actorDetailsBirthdayLabel, actorDetailsBirthdayValue, details.birthday)
            setInfo(actorDetailsDeathdayLabel, actorDetailsDeathdayValue, details.deathday)

            setInfo(actorDetailsBirthplaceLabel, actorDetailsBirthplaceValue, details.birthplace)

            val knownFor = details.knownFor
                .filter { it.isNotBlank() }
                .joinToString(separator = "\n")
                .takeIf { it.isNotBlank() }
            setInfo(actorDetailsKnownForLabel, actorDetailsKnownForValue, knownFor)

            val alsoKnown = details.alsoKnownAs.filter { it.isNotBlank() }
                .joinToString(separator = "\n")
                .takeIf { it.isNotBlank() }
            setInfo(actorDetailsAlsoKnownLabel, actorDetailsAlsoKnownValue, alsoKnown)

            setInfo(actorDetailsImdbLabel, actorDetailsImdbValue, details.imdbId)
            setInfo(actorDetailsHomepageLabel, actorDetailsHomepageValue, details.homepage)
        }
    }

    private fun showLoading() {
        binding?.apply {
            actorDetailsProgress.isVisible = true
            actorDetailsScroll.isVisible = false
            actorDetailsErrorGroup.isVisible = false
        }
    }

    private fun showError(throwable: Throwable) {
        binding?.apply {
            actorDetailsProgress.isVisible = false
            actorDetailsScroll.isVisible = false
            actorDetailsErrorGroup.isVisible = true
            val message = throwable.message ?: getString(R.string.actor_details_error)
            actorDetailsErrorText.text = message
        }
    }

    private fun setInfo(label: TextView, value: TextView, content: String?) {
        val hasContent = !content.isNullOrBlank()
        label.isVisible = hasContent
        value.isVisible = hasContent
        if (hasContent) {
            value.text = content
        }
    }

    private fun parseArgs(bundle: Bundle?): ActorDetailsArgs {
        val actorId = bundle?.getInt(ARG_ACTOR_ID, 0) ?: 0
        return ActorDetailsArgs(actorId)
    }
}

private data class ActorDetailsArgs(
    val actorId: Int,
)
