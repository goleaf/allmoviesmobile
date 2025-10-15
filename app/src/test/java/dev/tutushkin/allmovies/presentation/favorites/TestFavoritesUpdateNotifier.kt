package dev.tutushkin.allmovies.presentation.favorites

import dev.tutushkin.allmovies.presentation.favorites.sync.FavoritesUpdateNotifier
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow

class TestFavoritesUpdateNotifier : FavoritesUpdateNotifier {
    private val flow = MutableSharedFlow<Unit>(
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST
    )

    override val updates: SharedFlow<Unit> = flow

    override fun notifyFavoritesChanged() {
        flow.tryEmit(Unit)
    }
}
