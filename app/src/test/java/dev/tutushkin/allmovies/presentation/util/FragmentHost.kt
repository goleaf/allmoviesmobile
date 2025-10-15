package dev.tutushkin.allmovies.presentation.util

import androidx.annotation.StyleRes
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import dev.tutushkin.allmovies.R
import java.io.Closeable
import org.robolectric.Robolectric
import org.robolectric.android.controller.ActivityController

class FragmentHost<T : Fragment> internal constructor(
    private val controller: ActivityController<FragmentActivity>,
    val activity: FragmentActivity,
    val fragment: T
) : Closeable {

    override fun close() {
        controller.pause().stop().destroy()
    }
}

fun <T : Fragment> launchFragment(
    fragment: T,
    @StyleRes themeResId: Int = R.style.Theme_AppCompat
): FragmentHost<T> {
    val controller = Robolectric.buildActivity(FragmentActivity::class.java)
    val activity = controller.get()
    activity.setTheme(themeResId)
    controller.setup()
    activity.supportFragmentManager.beginTransaction()
        .replace(android.R.id.content, fragment)
        .commitNow()
    return FragmentHost(controller, activity, fragment)
}

inline fun <T : Fragment, R> FragmentHost<T>.withFragment(block: (T) -> R): R = block(fragment)
