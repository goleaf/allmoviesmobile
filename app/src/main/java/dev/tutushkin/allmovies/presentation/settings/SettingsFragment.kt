package dev.tutushkin.allmovies.presentation.settings

import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.RadioButton
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.settings.SettingsRepositoryImpl
import dev.tutushkin.allmovies.databinding.FragmentSettingsBinding
import dev.tutushkin.allmovies.domain.settings.AppSettings
import dev.tutushkin.allmovies.domain.settings.LanguageOption
import dev.tutushkin.allmovies.domain.settings.ThemeOption
import kotlinx.coroutines.launch

class SettingsFragment : Fragment(R.layout.fragment_settings) {

    private var _binding: FragmentSettingsBinding? = null
    private val binding get() = _binding!!

    private lateinit var repository: SettingsRepositoryImpl
    private val viewModel: SettingsViewModel by viewModels {
        SettingsViewModelFactory(repository)
    }

    private var suppressLanguageCallback = false
    private var suppressThemeCallback = false

    override fun onAttach(context: Context) {
        super.onAttach(context)
        repository = SettingsRepositoryImpl(context.applicationContext)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentSettingsBinding.bind(view)

        setupLanguageDropdown()
        setupThemeGroup()

        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.state.collect { settings ->
                    applySettings(settings)
                }
            }
        }
    }

    private fun setupLanguageDropdown() {
        val languageDisplayNames = LanguageOption.supported.map { option ->
            option.locale.getDisplayName(option.locale).replaceFirstChar { ch ->
                if (ch.isLowerCase()) ch.titlecase(option.locale) else ch.toString()
            }
        }
        val adapter = ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, languageDisplayNames)
        binding.settingsLanguageDropdown.setAdapter(adapter)
        binding.settingsLanguageDropdown.keyListener = null
        binding.settingsLanguageDropdown.setOnItemClickListener { _, _, position, _ ->
            if (!suppressLanguageCallback) {
                viewModel.onLanguageSelected(LanguageOption.supported[position])
            }
        }
    }

    private fun setupThemeGroup() {
        val themeIds = mapOf(
            R.id.settings_theme_default to ThemeOption.DEFAULT,
            R.id.settings_theme_dark to ThemeOption.DARK,
            R.id.settings_theme_ocean to ThemeOption.OCEAN
        )
        binding.settingsThemeGroup.setOnCheckedChangeListener { group, checkedId ->
            if (checkedId == -1 || suppressThemeCallback) {
                return@setOnCheckedChangeListener
            }
            val theme = themeIds[checkedId] ?: return@setOnCheckedChangeListener
            viewModel.onThemeSelected(theme)
            group.findViewById<RadioButton>(checkedId)?.isChecked = true
        }
    }

    private fun applySettings(settings: AppSettings) {
        suppressLanguageCallback = true
        val languageIndex = LanguageOption.supported.indexOf(settings.language)
        if (languageIndex >= 0) {
            binding.settingsLanguageDropdown.setText(binding.settingsLanguageDropdown.adapter.getItem(languageIndex).toString(), false)
        }
        suppressLanguageCallback = false

        suppressThemeCallback = true
        val checkedId = when (settings.theme) {
            ThemeOption.DEFAULT -> R.id.settings_theme_default
            ThemeOption.DARK -> R.id.settings_theme_dark
            ThemeOption.OCEAN -> R.id.settings_theme_ocean
        }
        if (binding.settingsThemeGroup.checkedRadioButtonId != checkedId) {
            binding.settingsThemeGroup.check(checkedId)
        }
        suppressThemeCallback = false
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    companion object {
        const val TAG = "SettingsFragment"
    }
}
