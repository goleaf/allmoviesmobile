package dev.tutushkin.allmovies

import android.content.res.Configuration
import android.os.Build
import android.os.LocaleList
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import dev.tutushkin.allmovies.R
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import java.util.Locale

@RunWith(AndroidJUnit4::class)
class LanguageResourcesInstrumentedTest {

    @Test
    fun russianLocaleProvidesTranslatedLabels() {
        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        val localizedContext = appContext.createConfigurationContext(appContext.resources.configuration.toLocalized(Locale("ru")))

        val entries = localizedContext.resources.getStringArray(R.array.language_entries)
        assertEquals(listOf("Английский", "Русский"), entries.toList())
        assertEquals("Язык", localizedContext.getString(R.string.menu_language))
        assertEquals("Выберите язык", localizedContext.getString(R.string.language_dialog_title))
    }

    @Test
    fun englishLocaleKeepsDefaultLabels() {
        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        val localizedContext = appContext.createConfigurationContext(appContext.resources.configuration.toLocalized(Locale.ENGLISH))

        val entries = localizedContext.resources.getStringArray(R.array.language_entries)
        assertEquals(listOf("English", "Russian"), entries.toList())
        assertEquals("Language", localizedContext.getString(R.string.menu_language))
        assertEquals("Choose language", localizedContext.getString(R.string.language_dialog_title))
    }
}

private fun Configuration.toLocalized(locale: Locale): Configuration {
    val newConfig = Configuration(this)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        newConfig.setLocales(LocaleList(locale))
    } else {
        newConfig.setLocale(locale)
    }
    return newConfig
}
