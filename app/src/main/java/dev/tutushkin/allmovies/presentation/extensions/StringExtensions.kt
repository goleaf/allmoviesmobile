package dev.tutushkin.allmovies.presentation.extensions

import java.util.Locale

private val slugReplacementRegex = "[^a-z0-9]+".toRegex()

fun String.toSlug(): String {
    val normalized = lowercase(Locale.US)
        .replace(slugReplacementRegex, "-")
        .trim('-')

    return if (normalized.isEmpty()) "movie" else normalized
}
