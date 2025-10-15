package dev.tutushkin.allmovies.presentation

import dev.tutushkin.allmovies.utils.logging.Logger

class TestLogger : Logger {
    data class Entry(val tag: String, val message: String, val throwable: Throwable?)

    private val _errors = mutableListOf<Entry>()
    val errors: List<Entry> get() = _errors

    override fun e(tag: String, message: String, throwable: Throwable?) {
        _errors += Entry(tag, message, throwable)
    }
}
