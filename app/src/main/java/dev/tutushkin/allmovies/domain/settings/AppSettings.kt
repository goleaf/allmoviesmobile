package dev.tutushkin.allmovies.domain.settings

import java.util.Locale

data class AppSettings(
    val language: LanguageOption,
    val theme: ThemeOption
)

enum class LanguageOption(val php4DvdCode: String, val locale: Locale) {
    EN("en", Locale("en")),
    NL("nl", Locale("nl")),
    SV("sv", Locale("sv")),
    FR("fr", Locale("fr")),
    PL("pl", Locale("pl")),
    DE("de", Locale("de")),
    IT("it", Locale("it")),
    CZ("cz", Locale("cs")),
    HU("hu", Locale("hu")),
    PT("pt", Locale("pt"));

    companion object {
        val supported: List<LanguageOption> = values().toList()

        fun fromPhp4DvdCode(code: String?): LanguageOption {
            if (code == null) return EN
            return values().firstOrNull { it.php4DvdCode.equals(code, ignoreCase = true) } ?: EN
        }
    }
}

enum class ThemeOption(
    val php4DvdKey: String,
    val overlayRes: Int,
    val displayNameRes: Int
) {
    DEFAULT("default", dev.tutushkin.allmovies.R.style.ThemeOverlay_AllMovies_Php4Dvd_Default, dev.tutushkin.allmovies.R.string.theme_default_name),
    DARK("dark", dev.tutushkin.allmovies.R.style.ThemeOverlay_AllMovies_Php4Dvd_Dark, dev.tutushkin.allmovies.R.string.theme_dark_name),
    OCEAN("ocean", dev.tutushkin.allmovies.R.style.ThemeOverlay_AllMovies_Php4Dvd_Ocean, dev.tutushkin.allmovies.R.string.theme_ocean_name);

    companion object {
        val supported: List<ThemeOption> = values().toList()

        fun fromPhp4DvdKey(key: String?): ThemeOption {
            if (key == null) return DEFAULT
            return values().firstOrNull { it.php4DvdKey.equals(key, ignoreCase = true) } ?: DEFAULT
        }
    }
}
