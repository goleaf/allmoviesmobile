package dev.tutushkin.allmovies.presentation.auth.login

import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.auth.AuthServiceLocator
import dev.tutushkin.allmovies.databinding.FragmentLoginBinding
import kotlinx.serialization.ExperimentalSerializationApi

@ExperimentalSerializationApi
class LoginFragment : Fragment(R.layout.fragment_login) {

    private var _binding: FragmentLoginBinding? = null
    private val binding get() = _binding!!

    private val viewModel: LoginViewModel by viewModels {
        LoginViewModelFactory(AuthServiceLocator.provideRepository(requireContext()))
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentLoginBinding.bind(view)
        setupListeners()
        observeState()
    }

    private fun setupListeners() {
        binding.loginButton.setOnClickListener {
            viewModel.login(
                binding.loginUsernameInput.text?.toString().orEmpty(),
                binding.loginPasswordInput.text?.toString().orEmpty()
            )
        }
        binding.loginGuestButton.setOnClickListener {
            viewModel.continueAsGuest()
        }
        binding.loginPasswordInput.setOnEditorActionListener { _, actionId, event ->
            val handled = actionId == EditorInfo.IME_ACTION_DONE ||
                event?.keyCode == KeyEvent.KEYCODE_ENTER
            if (handled) {
                binding.loginButton.performClick()
            }
            handled
        }
    }

    private fun observeState() {
        viewModel.state.observe(viewLifecycleOwner) { state ->
            when (state) {
                LoginUiState.Idle -> renderIdle()
                LoginUiState.Loading -> renderLoading()
                LoginUiState.Success -> renderSuccess()
                LoginUiState.Guest -> renderGuest()
                is LoginUiState.Error -> renderError(state.message)
            }
        }
    }

    private fun renderIdle() {
        binding.loginProgress.visibility = View.GONE
        binding.loginErrorText.visibility = View.GONE
    }

    private fun renderLoading() {
        binding.loginProgress.visibility = View.VISIBLE
        binding.loginErrorText.visibility = View.GONE
    }

    private fun renderSuccess() {
        binding.loginProgress.visibility = View.GONE
        binding.loginErrorText.visibility = View.GONE
        Toast.makeText(requireContext(), R.string.login_success_message, Toast.LENGTH_SHORT).show()
    }

    private fun renderGuest() {
        binding.loginProgress.visibility = View.GONE
        binding.loginErrorText.visibility = View.GONE
        Toast.makeText(requireContext(), R.string.login_guest_message, Toast.LENGTH_SHORT).show()
    }

    private fun renderError(message: String) {
        binding.loginProgress.visibility = View.GONE
        binding.loginErrorText.visibility = View.VISIBLE
        binding.loginErrorText.text = message
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
