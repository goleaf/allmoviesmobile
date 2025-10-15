package dev.tutushkin.allmovies.presentation.auth.profile

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.auth.AuthServiceLocator
import dev.tutushkin.allmovies.databinding.FragmentProfileBinding
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class ProfileFragment : Fragment(R.layout.fragment_profile) {

    private var _binding: FragmentProfileBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ProfileViewModel by viewModels {
        ProfileViewModelFactory(AuthServiceLocator.provideRepository(requireContext()))
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentProfileBinding.bind(view)
        observeProfile()
    }

    private fun observeProfile() {
        viewModel.profile.observe(viewLifecycleOwner) { state ->
            when (state) {
                ProfileUiState.Empty -> showEmptyState()
                is ProfileUiState.Data -> showProfile(state)
            }
        }
    }

    private fun showEmptyState() {
        binding.profileEmptyState.visibility = View.VISIBLE
        binding.profileDisplayName.visibility = View.GONE
        binding.profileUsername.visibility = View.GONE
        binding.profileRolesLabel.visibility = View.GONE
        binding.profileRoles.visibility = View.GONE
    }

    private fun showProfile(state: ProfileUiState.Data) {
        binding.profileEmptyState.visibility = View.GONE
        binding.profileDisplayName.visibility = View.VISIBLE
        binding.profileUsername.visibility = View.VISIBLE
        binding.profileRolesLabel.visibility = View.VISIBLE
        binding.profileRoles.visibility = View.VISIBLE

        binding.profileDisplayName.text = state.displayName
        binding.profileUsername.text = getString(R.string.profile_username_format, state.username)
        binding.profileRoles.text = state.roles
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
