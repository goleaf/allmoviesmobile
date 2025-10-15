package dev.tutushkin.allmovies.presentation.favorites.sync

import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow

interface FavoritesUpdateNotifier {
    val updates: SharedFlow<Unit>
    fun notifyFavoritesChanged()
}

class DefaultFavoritesUpdateNotifier : FavoritesUpdateNotifier {
    private val updatesFlow = MutableSharedFlow<Unit>(
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST
    )

    override val updates: SharedFlow<Unit> = updatesFlow.asSharedFlow()

    override fun notifyFavoritesChanged() {
        updatesFlow.tryEmit(Unit)
    }
}

object FavoritesUpdateNotifierProvider {
    val notifier: FavoritesUpdateNotifier by lazy { DefaultFavoritesUpdateNotifier() }
}
