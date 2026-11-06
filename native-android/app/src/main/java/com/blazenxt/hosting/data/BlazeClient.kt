package com.blazenxt.hosting.data

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.Cookie
import okhttp3.CookieJar
import okhttp3.HttpUrl
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import org.json.JSONArray
import org.json.JSONObject
import android.os.Handler
import android.os.Looper
import java.net.URLDecoder
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit

data class BlazeServer(
    val id: String,
    val uuid: String,
    val name: String,
    val node: String,
    val memoryMb: Int,
    val diskMb: Int,
    val description: String,
)

data class BlazeResources(
    val state: String,
    val memoryBytes: Long,
    val cpu: Double,
)

class BlazeClient(
    private val origin: String = "https://panel.nawazfx.com",
) {
    private val jar = MemoryCookieJar()
    private val http = OkHttpClient.Builder()
        .cookieJar(jar)
        .connectTimeout(20, TimeUnit.SECONDS)
        .readTimeout(40, TimeUnit.SECONDS)
        .build()

    var email: String = ""
        private set

    private fun xsrf(): String {
        val raw = jar.get(HttpUrl.parse(origin)!!).firstOrNull { it.name == "XSRF-TOKEN" }?.value
            ?: return ""
        return URLDecoder.decode(raw, "UTF-8")
    }

    private fun req(path: String, method: String = "GET", json: JSONObject? = null): Request {
        val b = Request.Builder()
            .url("$origin$path")
            .header("Accept", "application/json")
            .header("X-Requested-With", "XMLHttpRequest")
            .header("X-XSRF-TOKEN", xsrf())
        if (json != null) {
            b.method(method, json.toString().toRequestBody("application/json; charset=utf-8".toMediaType()))
        } else if (method != "GET") {
            b.method(method, ByteArray(0).toRequestBody(null))
        }
        return b.build()
    }

    private fun exec(request: Request): JSONObject? {
        http.newCall(request).execute().use { resp ->
            val body = resp.body?.string().orEmpty()
            if (resp.code == 204 || body.isBlank()) {
                if (!resp.isSuccessful) error(resp.message)
                return null
            }
            val parsed = runCatching { JSONObject(body) }.getOrElse { JSONObject().put("raw", body) }
            if (!resp.isSuccessful) {
                val err = parsed.optJSONArray("errors")?.optJSONObject(0)?.optString("detail")
                    ?: parsed.optString("message", resp.message)
                error(err)
            }
            return parsed
        }
    }

    suspend fun csrf() = withContext(Dispatchers.IO) {
        exec(req("/sanctum/csrf-cookie"))
        Unit
    }

    suspend fun login(user: String, password: String) = withContext(Dispatchers.IO) {
        csrf()
        val payload = JSONObject().put("user", user).put("password", password)
        exec(req("/auth/login", "POST", payload))
        val me = exec(req("/api/client/account"))
        email = me?.optJSONObject("attributes")?.optString("email").orEmpty()
            .ifBlank { user }
    }

    suspend fun logout() = withContext(Dispatchers.IO) {
        runCatching { exec(req("/auth/logout", "POST")) }
        jar.clear()
        email = ""
    }

    suspend fun servers(): List<BlazeServer> = withContext(Dispatchers.IO) {
        val root = exec(req("/api/client")) ?: return@withContext emptyList()
        val data: JSONArray = root.optJSONArray("data") ?: JSONArray()
        buildList {
            for (i in 0 until data.length()) {
                val a = data.getJSONObject(i).optJSONObject("attributes") ?: continue
                val limits = a.optJSONObject("limits") ?: JSONObject()
                add(
                    BlazeServer(
                        id = a.optString("identifier"),
                        uuid = a.optString("uuid"),
                        name = a.optString("name"),
                        node = a.optString("node"),
                        memoryMb = limits.optInt("memory"),
                        diskMb = limits.optInt("disk"),
                        description = a.optString("description"),
                    ),
                )
            }
        }
    }

    suspend fun resources(id: String): BlazeResources = withContext(Dispatchers.IO) {
        val root = exec(req("/api/client/servers/$id/resources"))
        val a = root?.optJSONObject("attributes") ?: JSONObject()
        val r = a.optJSONObject("resources") ?: JSONObject()
        BlazeResources(
            state = a.optString("current_state", "offline"),
            memoryBytes = r.optLong("memory_bytes"),
            cpu = r.optDouble("cpu_absolute"),
        )
    }

    suspend fun power(id: String, signal: String) = withContext(Dispatchers.IO) {
        exec(req("/api/client/servers/$id/power", "POST", JSONObject().put("signal", signal)))
        Unit
    }

    suspend fun openConsole(id: String, onLine: (String) -> Unit): WebSocket? = withContext(Dispatchers.IO) {
        val meta = runCatching { exec(req("/api/client/servers/$id/websocket")) }.getOrNull()
        val data = meta?.optJSONObject("data") ?: return null
        val token = data.optString("token")
        val socket = data.optString("socket")
        if (token.isBlank() || socket.isBlank()) return null
        return http.newWebSocket(
            Request.Builder().url(socket).build(),
            object : WebSocketListener() {
                override fun onOpen(webSocket: WebSocket, response: okhttp3.Response) {
                    webSocket.send(JSONObject().put("event", "auth").put("args", JSONArray().put(token)).toString())
                }

                override fun onMessage(webSocket: WebSocket, text: String) {
                    val msg = runCatching { JSONObject(text) }.getOrNull() ?: return
                    when (msg.optString("event")) {
                        "auth success" ->
                            webSocket.send(JSONObject().put("event", "send logs").put("args", JSONArray().put(null)).toString())
                        "console output", "install output" -> {
                            val line = msg.optJSONArray("args")?.optString(0).orEmpty()
                            Handler(Looper.getMainLooper()).post { onLine(line) }
                        }
                    }
                }
            },
        )
    }
}

private class MemoryCookieJar : CookieJar {
    private val store = ConcurrentHashMap<String, List<Cookie>>()
    override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
        val map = (store[url.host] ?: emptyList()).associateBy { it.name }.toMutableMap()
        cookies.forEach { map[it.name] = it }
        store[url.host] = map.values.toList()
    }

    override fun loadForRequest(url: HttpUrl): List<Cookie> = store[url.host] ?: emptyList()
    fun get(url: HttpUrl) = loadForRequest(url)
    fun clear() = store.clear()
}
