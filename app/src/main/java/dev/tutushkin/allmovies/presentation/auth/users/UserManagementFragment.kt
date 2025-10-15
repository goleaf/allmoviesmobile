package dev.tutushkin.allmovies.presentation.auth.users

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.auth.AuthServiceLocator
import dev.tutushkin.allmovies.databinding.FragmentUserManagementBinding
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class UserManagementFragment : Fragment(R.layout.fragment_user_management) {

    private var _binding: FragmentUserManagementBinding? = null
    private val binding get() = _binding!!

    private val viewModel: UserManagementViewModel by viewModels {
        UserManagementViewModelFactory(AuthServiceLocator.provideRepository(requireContext()))
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentUserManagementBinding.bind(view)
        observeState()
    }

    private fun observeState() {
        viewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                UserManagementUiState.Loading -> renderLoading()
                UserManagementUiState.AccessDenied -> renderMessage(getString(R.string.user_management_access_denied))
                is UserManagementUiState.Data -> renderRoles(state.roles)
                is UserManagementUiState.Error -> renderMessage(state.message)
            }
        }
    }

    private fun renderLoading() {
        binding.userManagementProgress.visibility = View.VISIBLE
        binding.userManagementRoles.visibility = View.GONE
        binding.userManagementMessage.visibility = View.GONE
    }

    private fun renderRoles(roles: List<String>) {
        binding.userManagementProgress.visibility = View.GONE
        binding.userManagementMessage.visibility = View.GONE
        binding.userManagementRoles.visibility = View.VISIBLE
        binding.userManagementRoles.text = roles.joinToString(separator = "\n")
    }

    private fun renderMessage(message: String) {
        binding.userManagementProgress.visibility = View.GONE
        binding.userManagementRoles.visibility = View.GONE
        binding.userManagementMessage.visibility = View.VISIBLE
        binding.userManagementMessage.text = message
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
