package dev.tutushkin.allmovies.presentation.common

import android.content.Context
import androidx.annotation.StringRes

sealed class UiText {
    data class Resource(
        @StringRes val resId: Int,
        val args: List<Any> = emptyList()
    ) : UiText()

    data class DynamicString(val value: String) : UiText()

    fun asString(context: Context): String = when (this) {
        is Resource -> if (args.isEmpty()) {
            context.getString(resId)
        } else {
            context.getString(resId, *args.toTypedArray())
        }

        is DynamicString -> value
    }
}
