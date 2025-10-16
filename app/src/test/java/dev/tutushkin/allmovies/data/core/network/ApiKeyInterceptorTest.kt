package dev.tutushkin.allmovies.data.core.network

import dev.tutushkin.allmovies.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class ApiKeyInterceptorTest {

    private lateinit var mockWebServer: MockWebServer

    @Before
    fun setUp() {
        mockWebServer = MockWebServer()
        mockWebServer.start()
    }

    @After
    fun tearDown() {
        mockWebServer.shutdown()
    }

    @Test
    fun `interceptor adds api key to every request`() {
        mockWebServer.enqueue(MockResponse().setResponseCode(200).setBody("{}"))

        val client = OkHttpClient.Builder()
            .addInterceptor(ApiKeyInterceptor())
            .build()

        val request = Request.Builder()
            .url(mockWebServer.url("/configuration?language=en-US"))
            .build()

        val response = client.newCall(request).execute()

        assertTrue(response.isSuccessful)
        response.close()

        val recorded = mockWebServer.takeRequest()
        val url = recorded.requestUrl
        requireNotNull(url)

        assertEquals(BuildConfig.API_KEY, url.queryParameter("api_key"))
        assertEquals("en-US", url.queryParameter("language"))
    }
}
