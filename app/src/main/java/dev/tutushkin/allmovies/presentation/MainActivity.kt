package dev.tutushkin.allmovies.presentation

import android.content.Context
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.util.TypedValue
import androidx.annotation.AttrRes
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.data.settings.SettingsRepositoryImpl
import dev.tutushkin.allmovies.databinding.ActivityMainBinding
import dev.tutushkin.allmovies.domain.settings.AppSettings
import dev.tutushkin.allmovies.domain.settings.SettingsRepository
import dev.tutushkin.allmovies.presentation.movies.view.MoviesFragment
import dev.tutushkin.allmovies.presentation.settings.SettingsFragment
import dev.tutushkin.allmovies.utils.LocaleUtils
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.ExperimentalSerializationApi

// TODO Add loader
// TODO Add save favorites
// TODO Add movie search
// TODO Add info about actors (new screen)
// TODO Use Navigation
// TODO Use DI
// TODO Add column alignment to the RecyclerView
// TODO Optimize image sizes dynamically based on a display/network speed/settings
// TODO Add tests
// TODO Add logging
// TODO Replace Toasts with SnackBars

@ExperimentalSerializationApi
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var settingsRepository: SettingsRepository
    private lateinit var currentSettings: AppSettings

    override fun attachBaseContext(newBase: Context) {
        val repository = SettingsRepositoryImpl(newBase)
        val snapshot = runBlocking { repository.getSettingsSnapshot() }
        val wrapped = LocaleUtils.wrapContext(newBase, snapshot.language.locale)
        settingsRepository = repository
        currentSettings = snapshot
        super.attachBaseContext(wrapped)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        theme.applyStyle(currentSettings.theme.overlayRes, true)
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.toolbar)
        binding.toolbar.setNavigationOnClickListener {
            onBackPressedDispatcher.onBackPressed()
        }

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.main_container, MoviesFragment())
                .commit()
        }

        supportFragmentManager.addOnBackStackChangedListener { updateToolbarState() }
        updateToolbarState()

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                settingsRepository.settings.collect { settings ->
                    val requiresRecreate =
                        settings.language != currentSettings.language ||
                            settings.theme != currentSettings.theme
                    currentSettings = settings
                    if (requiresRecreate) {
                        recreate()
                    } else {
                        updateToolbarState()
                    }
                }
            }
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                onBackPressedDispatcher.onBackPressed()
                true
            }
            R.id.menu_settings -> {
                openSettings()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun openSettings() {
        val current = supportFragmentManager.findFragmentByTag(SettingsFragment.TAG)
        if (current == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.main_container, SettingsFragment(), SettingsFragment.TAG)
                .addToBackStack(SettingsFragment.TAG)
                .commit()
        }
    }

    private fun updateToolbarState() {
        val isRoot = supportFragmentManager.backStackEntryCount == 0
        supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(!isRoot)
            title = if (isRoot) {
                getString(R.string.app_name)
            } else {
                getString(R.string.settings_title)
            }
        }
        binding.toolbar.navigationIcon?.setTint(resolveColor(R.attr.colorHeaderText))
    }

    private fun resolveColor(@AttrRes attr: Int): Int {
        val typedValue = TypedValue()
        theme.resolveAttribute(attr, typedValue, true)
        return typedValue.data
    }
}