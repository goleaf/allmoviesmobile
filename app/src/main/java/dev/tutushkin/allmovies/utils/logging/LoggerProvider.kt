package dev.tutushkin.allmovies.utils.logging

object LoggerProvider {
    val logger: Logger by lazy { AndroidLogger() }
}
