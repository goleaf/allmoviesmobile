package dev.tutushkin.allmovies.utils

import dev.tutushkin.allmovies.data.movies.UNKNOWN_YEAR
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

class Util {
    companion object {
        private const val SOURCE_DATE_PATTERN = "yyyy-MM-dd"
        private const val TARGET_YEAR_PATTERN = "yyyy"

        fun dateToYear(value: String): String {
            if (value.isBlank()) return UNKNOWN_YEAR

            val sourceFormat = SimpleDateFormat(SOURCE_DATE_PATTERN, Locale.getDefault()).apply {
                isLenient = false
            }
            val targetFormat = SimpleDateFormat(TARGET_YEAR_PATTERN, Locale.getDefault())

            val parsedDate = try {
                sourceFormat.parse(value)
            } catch (exception: ParseException) {
                null
            }

            return parsedDate?.let(targetFormat::format) ?: UNKNOWN_YEAR
        }
    }
}
