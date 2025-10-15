package dev.tutushkin.allmovies.presentation.settings.view

import android.os.Bundle
import android.util.Patterns
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.google.android.material.textfield.TextInputLayout
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.settings.SettingsRepositoryImpl
import dev.tutushkin.allmovies.data.settings.local.settingsDataStore
import dev.tutushkin.allmovies.databinding.FragmentSettingsBinding
import dev.tutushkin.allmovies.domain.settings.models.AppSettings
import dev.tutushkin.allmovies.presentation.settings.viewmodel.SettingsEvent
import dev.tutushkin.allmovies.presentation.settings.viewmodel.SettingsState
import dev.tutushkin.allmovies.presentation.settings.viewmodel.SettingsViewModel
import dev.tutushkin.allmovies.presentation.settings.viewmodel.SettingsViewModelFactory
import kotlinx.coroutines.Dispatchers

class SettingsFragment : Fragment(R.layout.fragment_settings) {

    private var _binding: FragmentSettingsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: SettingsViewModel by viewModels {
        val application = requireActivity().application
        val repository = SettingsRepositoryImpl(application.settingsDataStore, Dispatchers.IO)
        SettingsViewModelFactory(repository)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentSettingsBinding.bind(view)

        binding.saveButton.setOnClickListener {
            val settings = buildSettings() ?: return@setOnClickListener
            viewModel.save(settings)
        }

        viewModel.state.observe(viewLifecycleOwner, ::renderState)
        viewModel.events.observe(viewLifecycleOwner) { event ->
            when (event) {
                SettingsEvent.Saved -> {
                    Toast.makeText(requireContext(), R.string.settings_saved_message, Toast.LENGTH_SHORT).show()
                    viewModel.onEventConsumed()
                }
                null -> Unit
            }
        }
    }

    private fun renderState(state: SettingsState) {
        when (state) {
            is SettingsState.Content -> populate(state.settings)
            is SettingsState.Error -> {
                val message = state.error.message ?: state.error::class.java.simpleName
                Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
            }
            SettingsState.Loading -> Unit
        }
    }

    private fun populate(settings: AppSettings) {
        clearErrors()
        with(binding) {
            defaultPageInput.setText(settings.defaultPage.toString())
            resultsPerPageInput.setText(settings.resultsPerPage.toString())
            castLimitInput.setText(settings.castLimit.toString())
            httpsTmdbSwitch.isChecked = settings.enforceHttpsForTmdb
            httpsImdbSwitch.isChecked = settings.enforceHttpsForImdb
            imdbLanguageInput.setText(settings.imdbLanguageOverride)
            imdbIpInput.setText(settings.imdbIpOverride)
            youtubeKeyInput.setText(settings.youtubeApiKey)
        }
    }

    private fun buildSettings(): AppSettings? {
        clearErrors()
        val defaultPage = binding.defaultPageInput.text?.toString().orEmpty().trim()
        val resultsPerPage = binding.resultsPerPageInput.text?.toString().orEmpty().trim()
        val castLimit = binding.castLimitInput.text?.toString().orEmpty().trim()
        val imdbLanguage = binding.imdbLanguageInput.text?.toString().orEmpty().trim()
        val imdbIp = binding.imdbIpInput.text?.toString().orEmpty().trim()
        val youtubeKey = binding.youtubeKeyInput.text?.toString().orEmpty().trim()

        val defaultPageValue = defaultPage.toPositiveInt(binding.defaultPageLayout) ?: return null
        val resultsPerPageValue = resultsPerPage.toPositiveInt(binding.resultsPerPageLayout) ?: return null
        val castLimitValue = castLimit.toNonNegativeInt(binding.castLimitLayout) ?: return null

        if (imdbLanguage.isNotBlank() && !LANGUAGE_REGEX.matches(imdbLanguage)) {
            binding.imdbLanguageLayout.error = getString(R.string.settings_error_invalid_language)
            return null
        }

        if (imdbIp.isNotBlank() && !Patterns.IP_ADDRESS.matcher(imdbIp).matches()) {
            binding.imdbIpLayout.error = getString(R.string.settings_error_invalid_ip)
            return null
        }

        if (youtubeKey.isNotBlank() && !YOUTUBE_KEY_REGEX.matches(youtubeKey)) {
            binding.youtubeKeyLayout.error = getString(R.string.settings_error_invalid_youtube_key)
            return null
        }

        return AppSettings(
            defaultPage = defaultPageValue,
            resultsPerPage = resultsPerPageValue,
            castLimit = castLimitValue,
            enforceHttpsForTmdb = binding.httpsTmdbSwitch.isChecked,
            enforceHttpsForImdb = binding.httpsImdbSwitch.isChecked,
            imdbLanguageOverride = imdbLanguage,
            imdbIpOverride = imdbIp,
            youtubeApiKey = youtubeKey
        )
    }

    private fun clearErrors() {
        listOf(
            binding.defaultPageLayout,
            binding.resultsPerPageLayout,
            binding.castLimitLayout,
            binding.imdbLanguageLayout,
            binding.imdbIpLayout,
            binding.youtubeKeyLayout
        ).forEach { it.error = null }
    }

    private fun String.toPositiveInt(layout: TextInputLayout): Int? {
        val value = toIntOrNull()
        return if (value != null && value > 0) {
            value
        } else {
            layout.error = getString(R.string.settings_error_invalid_integer)
            null
        }
    }

    private fun String.toNonNegativeInt(layout: TextInputLayout): Int? {
        val value = toIntOrNull()
        return if (value != null && value >= 0) {
            value
        } else {
            layout.error = getString(R.string.settings_error_invalid_integer)
            null
        }
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    companion object {
        private val LANGUAGE_REGEX = Regex(
            "^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*(?:;q=(?:0(?:\\.\\d{1,3})?|1(?:\\.0{1,3})?))?" +
                "(?:,\\s*[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*(?:;q=(?:0(?:\\.\\d{1,3})?|1(?:\\.0{1,3})?))?)*$"
        )
        private val YOUTUBE_KEY_REGEX = Regex("^AIza[0-9A-Za-z_-]{35}$")
    }
}

