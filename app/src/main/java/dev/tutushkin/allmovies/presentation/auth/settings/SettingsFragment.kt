package dev.tutushkin.allmovies.presentation.auth.settings

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.auth.AuthServiceLocator
import dev.tutushkin.allmovies.databinding.FragmentSettingsBinding
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class SettingsFragment : Fragment(R.layout.fragment_settings) {

    private var _binding: FragmentSettingsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: SettingsViewModel by viewModels {
        SettingsViewModelFactory(AuthServiceLocator.provideRepository(requireContext()))
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentSettingsBinding.bind(view)
        setupListeners()
        observeState()
    }

    private fun setupListeners() {
        binding.settingsRefreshSession.setOnClickListener {
            viewModel.refreshSession()
        }
        binding.settingsLogout.setOnClickListener {
            showLogoutConfirmation()
        }
    }

    private fun observeState() {
        viewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                SettingsUiState.Idle -> renderIdle()
                SettingsUiState.Loading -> renderLoading()
                SettingsUiState.SessionRefreshed -> renderStatus(getString(R.string.settings_session_refreshed))
                SettingsUiState.LoggedOut -> renderLoggedOut()
                is SettingsUiState.Error -> renderError(state.message)
            }
        }
    }

    private fun renderIdle() {
        binding.settingsStatus.visibility = View.GONE
    }

    private fun renderLoading() {
        binding.settingsStatus.visibility = View.VISIBLE
        binding.settingsStatus.text = getString(R.string.settings_loading)
    }

    private fun renderStatus(message: String) {
        binding.settingsStatus.visibility = View.VISIBLE
        binding.settingsStatus.text = message
    }

    private fun renderLoggedOut() {
        renderStatus(getString(R.string.settings_logged_out))
        Toast.makeText(requireContext(), R.string.settings_logged_out_toast, Toast.LENGTH_SHORT).show()
    }

    private fun renderError(message: String) {
        binding.settingsStatus.visibility = View.VISIBLE
        binding.settingsStatus.text = message
    }

    private fun showLogoutConfirmation() {
        MaterialAlertDialogBuilder(requireContext())
            .setTitle(R.string.settings_logout_title)
            .setMessage(R.string.settings_logout_message)
            .setPositiveButton(R.string.settings_logout_confirm) { _, _ ->
                viewModel.logout()
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
