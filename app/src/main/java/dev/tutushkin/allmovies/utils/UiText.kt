package dev.tutushkin.allmovies.utils

import android.content.Context
import android.content.res.Resources
import androidx.annotation.StringRes

sealed class UiText {
    data class StringResource(
        @StringRes val resId: Int,
        val args: List<Any> = emptyList()
    ) : UiText()

    data class DynamicString(val value: String) : UiText()

    fun resolve(resources: Resources): String = when (this) {
        is StringResource -> resources.getString(resId, *args.toTypedArray(resources))
        is DynamicString -> value
    }

    fun resolve(context: Context): String = resolve(context.resources)

    companion object {
        fun stringResource(@StringRes resId: Int, vararg args: Any): UiText {
            return StringResource(resId, args.toList())
        }

        fun dynamicString(value: String): UiText {
            return DynamicString(value)
        }
    }
}

private fun List<Any>.toTypedArray(resources: Resources): Array<Any?> {
    return map { arg ->
        when (arg) {
            is UiText -> arg.resolve(resources)
            else -> arg
        }
    }.toTypedArray()
}
