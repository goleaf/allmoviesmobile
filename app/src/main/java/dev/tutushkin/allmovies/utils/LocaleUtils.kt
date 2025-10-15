package dev.tutushkin.allmovies.utils

import android.content.Context
import android.os.Build
import android.os.LocaleList
import android.content.res.Configuration
import java.util.Locale

object LocaleUtils {

    fun wrapContext(context: Context, locale: Locale): Context {
        Locale.setDefault(locale)
        val resources = context.resources
        val configuration = Configuration(resources.configuration)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.setLocale(locale)
            configuration.setLayoutDirection(locale)
            configuration.setLocales(LocaleList(locale))
            return context.createConfigurationContext(configuration)
        }
        configuration.setLocale(locale)
        configuration.setLayoutDirection(locale)
        resources.updateConfiguration(configuration, resources.displayMetrics)
        return context
    }
}
