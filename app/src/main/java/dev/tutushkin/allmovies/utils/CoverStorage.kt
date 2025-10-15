package dev.tutushkin.allmovies.utils

import android.content.Context
import android.net.Uri
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.util.UUID

object CoverStorage {

    suspend fun cacheCover(context: Context, source: Uri): Uri = withContext(Dispatchers.IO) {
        val resolver = context.contentResolver
        val inputStream = resolver.openInputStream(source)
            ?: throw IllegalStateException("Unable to open source uri: $source")
        inputStream.use {
            val file = createTempCoverFile(context)
            FileOutputStream(file).use { output ->
                copyStream(it, output)
            }
            Uri.fromFile(file)
        }
    }

    suspend fun cacheCover(context: Context, bytes: ByteArray): Uri = withContext(Dispatchers.IO) {
        val file = createTempCoverFile(context)
        FileOutputStream(file).use { output ->
            output.write(bytes)
        }
        Uri.fromFile(file)
    }

    suspend fun removeCover(context: Context, uri: Uri) = withContext(Dispatchers.IO) {
        if (uri.scheme == "file") {
            kotlin.runCatching {
                File(uri.path ?: return@runCatching).takeIf { it.exists() }?.delete()
            }
        } else {
            context.contentResolver.delete(uri, null, null)
        }
    }

    private fun createTempCoverFile(context: Context): File {
        val directory = File(context.cacheDir, "covers")
        if (!directory.exists()) {
            directory.mkdirs()
        }
        val fileName = "cover_${UUID.randomUUID()}"
        return File(directory, fileName)
    }

    private fun copyStream(input: InputStream, output: FileOutputStream) {
        val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
        while (true) {
            val read = input.read(buffer)
            if (read <= 0) break
            output.write(buffer, 0, read)
        }
    }
}
