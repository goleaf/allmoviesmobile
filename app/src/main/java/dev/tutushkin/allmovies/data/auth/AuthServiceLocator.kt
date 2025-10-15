package dev.tutushkin.allmovies.data.auth

import android.content.Context
import dev.tutushkin.allmovies.data.auth.local.AuthLocalDataSourceImpl
import dev.tutushkin.allmovies.data.auth.local.userPreferencesDataStore
import dev.tutushkin.allmovies.data.auth.network.AuthNetworkModule
import dev.tutushkin.allmovies.data.auth.remote.AuthRemoteDataSourceImpl
import dev.tutushkin.allmovies.domain.auth.AuthRepository
import kotlinx.serialization.ExperimentalSerializationApi

object AuthServiceLocator {

    @Volatile
    private var repository: AuthRepository? = null

    @ExperimentalSerializationApi
    fun provideRepository(context: Context): AuthRepository {
        val existing = repository
        if (existing != null) {
            return existing
        }
        synchronized(this) {
            val current = repository
            if (current != null) {
                return current
            }
            val remote = AuthRemoteDataSourceImpl(AuthNetworkModule.authApi)
            val local = AuthLocalDataSourceImpl(context.applicationContext.userPreferencesDataStore)
            val repo = AuthRepositoryImpl(remote, local)
            repository = repo
            return repo
        }
    }
}
