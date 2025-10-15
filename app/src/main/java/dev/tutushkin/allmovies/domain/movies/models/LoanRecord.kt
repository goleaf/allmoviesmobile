package dev.tutushkin.allmovies.domain.movies.models

data class LoanRecord(
    val id: Long,
    val movieId: Int,
    val borrowerName: String,
    val loanDate: Long,
    val returnDate: Long?
)
