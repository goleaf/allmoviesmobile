package dev.tutushkin.allmovies.presentation

import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.commit
import androidx.lifecycle.lifecycleScope
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.auth.AuthServiceLocator
import dev.tutushkin.allmovies.databinding.ActivityMainBinding
import dev.tutushkin.allmovies.domain.auth.AuthState
import dev.tutushkin.allmovies.presentation.auth.login.LoginFragment
import dev.tutushkin.allmovies.presentation.auth.profile.ProfileFragment
import dev.tutushkin.allmovies.presentation.auth.settings.SettingsFragment
import dev.tutushkin.allmovies.presentation.auth.users.UserManagementFragment
import dev.tutushkin.allmovies.presentation.main.MainEvent
import dev.tutushkin.allmovies.presentation.main.MainViewModel
import dev.tutushkin.allmovies.presentation.main.MainViewModelFactory
import dev.tutushkin.allmovies.presentation.main.ToolbarState
import dev.tutushkin.allmovies.presentation.movies.view.MoviesFragment
import kotlinx.coroutines.flow.collect
import kotlinx.serialization.ExperimentalSerializationApi

private const val TAG_LOGIN = "login"
private const val TAG_MOVIES = "movies"
private const val TAG_PROFILE = "profile"
private const val TAG_SETTINGS = "settings"
private const val TAG_USERS = "users"

@ExperimentalSerializationApi
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    private val mainViewModel: MainViewModel by viewModels {
        MainViewModelFactory(AuthServiceLocator.provideRepository(this))
    }

    private var toolbarState: ToolbarState = ToolbarState(
        showProfile = false,
        showSettings = false,
        showUserManagement = false,
        showLogout = false
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.mainToolbar)
        observeViewModel()
    }

    private fun observeViewModel() {
        mainViewModel.authState.observe(this) { state ->
            when (state) {
                AuthState.Unauthenticated -> showLogin()
                AuthState.Guest -> showMovies(guestMode = true)
                is AuthState.Authenticated -> showMovies(guestMode = false)
                is AuthState.SessionExpired -> showLogin()
            }
        }

        mainViewModel.toolbarState.observe(this) { state ->
            toolbarState = state
            invalidateOptionsMenu()
        }

        lifecycleScope.launchWhenStarted {
            mainViewModel.events.collect { event ->
                when (event) {
                    MainEvent.SessionExpired -> showSessionExpiredDialog()
                }
            }
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onPrepareOptionsMenu(menu: Menu): Boolean {
        menu.findItem(R.id.menu_profile)?.isVisible = toolbarState.showProfile
        menu.findItem(R.id.menu_settings)?.isVisible = toolbarState.showSettings
        menu.findItem(R.id.menu_users)?.isVisible = toolbarState.showUserManagement
        menu.findItem(R.id.menu_logout)?.isVisible = toolbarState.showLogout
        return super.onPrepareOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean = when (item.itemId) {
        R.id.menu_profile -> {
            navigateToFragment(ProfileFragment(), TAG_PROFILE)
            true
        }
        R.id.menu_settings -> {
            navigateToFragment(SettingsFragment(), TAG_SETTINGS)
            true
        }
        R.id.menu_users -> {
            navigateToFragment(UserManagementFragment(), TAG_USERS)
            true
        }
        R.id.menu_logout -> {
            showLogoutConfirmation()
            true
        }
        else -> super.onOptionsItemSelected(item)
    }

    private fun showLogin() {
        supportFragmentManager.popBackStack(null, androidx.fragment.app.FragmentManager.POP_BACK_STACK_INCLUSIVE)
        navigateToFragment(LoginFragment(), TAG_LOGIN, addToBackStack = false)
    }

    private fun showMovies(guestMode: Boolean) {
        supportFragmentManager.popBackStack(null, androidx.fragment.app.FragmentManager.POP_BACK_STACK_INCLUSIVE)
        val fragment = MoviesFragment.newInstance(guestMode)
        navigateToFragment(fragment, TAG_MOVIES, addToBackStack = false)
    }

    private fun navigateToFragment(fragment: androidx.fragment.app.Fragment, tag: String, addToBackStack: Boolean = true) {
        val existing = supportFragmentManager.findFragmentByTag(tag)
        supportFragmentManager.commit {
            setReorderingAllowed(true)
            replace(R.id.main_container, existing ?: fragment, tag)
            if (addToBackStack) addToBackStack(tag)
        }
    }

    private fun showLogoutConfirmation() {
        MaterialAlertDialogBuilder(this)
            .setTitle(R.string.settings_logout_title)
            .setMessage(R.string.settings_logout_message)
            .setPositiveButton(R.string.settings_logout_confirm) { _, _ ->
                mainViewModel.requestLogout()
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    private fun showSessionExpiredDialog() {
        MaterialAlertDialogBuilder(this)
            .setTitle(R.string.session_expired_title)
            .setMessage(R.string.session_expired_message)
            .setPositiveButton(android.R.string.ok, null)
            .show()
    }
}
