package dev.tutushkin.allmovies.utils.logging

interface Logger {
    fun e(tag: String, message: String, throwable: Throwable? = null)
}
