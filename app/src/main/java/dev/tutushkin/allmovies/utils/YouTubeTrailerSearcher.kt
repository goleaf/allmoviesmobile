package dev.tutushkin.allmovies.utils

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.HttpUrl
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

class YouTubeTrailerSearcher(
    private val client: OkHttpClient,
    private val apiKey: String
) {

    suspend fun search(query: String): Result<String> = withContext(Dispatchers.IO) {
        runCatching {
            require(query.isNotBlank()) { "Query must not be blank" }
            require(apiKey.isNotBlank()) { "YouTube API key is missing" }

            val url: HttpUrl = HttpUrl.Builder()
                .scheme("https")
                .host("www.googleapis.com")
                .addPathSegment("youtube")
                .addPathSegment("v3")
                .addPathSegment("search")
                .addQueryParameter("part", "snippet")
                .addQueryParameter("maxResults", "1")
                .addQueryParameter("q", query)
                .addQueryParameter("type", "video")
                .addQueryParameter("videoEmbeddable", "true")
                .addQueryParameter("key", apiKey)
                .build()

            val request = Request.Builder()
                .get()
                .url(url)
                .build()

            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) {
                    throw IllegalStateException("YouTube search failed with code ${response.code}")
                }

                val body = response.body?.string() ?: throw IllegalStateException("Empty response")
                val json = JSONObject(body)
                val items = json.optJSONArray("items") ?: throw NoSuchElementException("No results")
                if (items.length() == 0) {
                    throw NoSuchElementException("No results")
                }

                val first = items.getJSONObject(0)
                val id = first.optJSONObject("id")
                    ?: throw IllegalStateException("Unexpected response structure")
                val videoId = id.optString("videoId")
                if (videoId.isNullOrBlank()) {
                    throw IllegalStateException("Missing video id")
                }
                "https://www.youtube.com/watch?v=$videoId"
            }
        }
    }
}
