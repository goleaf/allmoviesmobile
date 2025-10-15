package dev.tutushkin.allmovies

import android.content.Context
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import dev.tutushkin.allmovies.domain.settings.LanguageOption
import dev.tutushkin.allmovies.R
import dev.tutushkin.allmovies.utils.LocaleUtils
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class LocalizationInstrumentationTest {

    @Test
    fun menuSettings_isLocalizedForSupportedLanguages() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val expected = mapOf(
            LanguageOption.EN to "Settings",
            LanguageOption.NL to "Instellingen",
            LanguageOption.SV to "Inställningar",
            LanguageOption.FR to "Paramètres",
            LanguageOption.PL to "Ustawienia",
            LanguageOption.DE to "Einstellungen",
            LanguageOption.IT to "Impostazioni",
            LanguageOption.CZ to "Nastavení",
            LanguageOption.HU to "Beállítások",
            LanguageOption.PT to "Configurações"
        )

        expected.forEach { (language, value) ->
            val localized = context.withLocale(language)
            assertEquals(
                "Unexpected translation for menu_settings in ${language.php4DvdCode}",
                value,
                localized.getString(R.string.menu_settings)
            )
        }
    }

    @Test
    fun moviesDuration_usesLocalizedUnits() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val hungarian = context.withLocale(LanguageOption.HU)
        assertEquals("120 perc", hungarian.getString(R.string.movies_list_duration, 120))

        val dutch = context.withLocale(LanguageOption.NL)
        assertEquals("120 min", dutch.getString(R.string.movies_list_duration, 120))
    }

    private fun Context.withLocale(language: LanguageOption): Context {
        return LocaleUtils.wrapContext(this, language.locale)
    }
}
