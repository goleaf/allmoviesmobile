package dev.tutushkin.allmovies.domain.movies.models

data class Certification(
    val code: String = "",
    val label: String = ""
) {
    companion object {
        val EMPTY = Certification()
    }
}
