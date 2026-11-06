package com.blazenxt.hosting

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.blazenxt.hosting.data.BlazeClient
import com.blazenxt.hosting.data.BlazeServer
import com.blazenxt.hosting.ui.Bad
import com.blazenxt.hosting.ui.Bg
import com.blazenxt.hosting.ui.BlazeTheme
import com.blazenxt.hosting.ui.Card
import com.blazenxt.hosting.ui.Ember
import com.blazenxt.hosting.ui.EmberBright
import com.blazenxt.hosting.ui.Muted
import com.blazenxt.hosting.ui.Ok
import com.blazenxt.hosting.ui.Panel
import kotlinx.coroutines.launch
import okhttp3.WebSocket

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            BlazeTheme { BlazeRoot() }
        }
    }
}

private enum class Page { Splash, Login, Home, Server }

@Composable
private fun BlazeRoot() {
    val api = remember { BlazeClient() }
    var page by remember { mutableStateOf(Page.Splash) }
    var servers by remember { mutableStateOf(listOf<BlazeServer>()) }
    var current by remember { mutableStateOf<BlazeServer?>(null) }
    var query by remember { mutableStateOf("") }
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        page = try {
            api.csrf()
            servers = api.servers()
            Page.Home
        } catch (_: Throwable) {
            Page.Login
        }
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0x33C94F59), Bg, Bg),
                ),
            ),
    ) {
        when (page) {
            Page.Splash -> Splash()
            Page.Login -> Login(onGo = { u, p, onErr, onBusy ->
                scope.launch {
                    onBusy(true)
                    try {
                        api.login(u, p)
                        servers = api.servers()
                        page = Page.Home
                    } catch (t: Throwable) {
                        onErr(t.message ?: "Login failed")
                    } finally {
                        onBusy(false)
                    }
                }
            })
            Page.Home -> Home(
                email = api.email,
                servers = servers.filter { query.isBlank() || it.name.contains(query, true) },
                query = query,
                onQuery = { query = it },
                onOpen = { current = it; page = Page.Server },
                onPower = { id, sig -> scope.launch { runCatching { api.power(id, sig) }; servers = runCatching { api.servers() }.getOrDefault(servers) } },
                onLogout = { scope.launch { api.logout(); page = Page.Login } },
                api = api,
            )
            Page.Server -> current?.let { srv ->
                ServerPage(
                    server = srv,
                    api = api,
                    onBack = { page = Page.Home; current = null },
                )
            }
        }
    }
}

@Composable
private fun Splash() {
    Column(Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
        Image(painterResource(R.drawable.logo), null, Modifier.size(96.dp).clip(RoundedCornerShape(24.dp)))
        Spacer(Modifier.height(16.dp))
        Text("Blaze Hosting", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        Text("1.0.0 · isolated", color = Muted, fontSize = 13.sp)
        Spacer(Modifier.height(24.dp))
        CircularProgressIndicator(color = Ember, strokeWidth = 2.dp, modifier = Modifier.size(22.dp))
    }
}

@Composable
private fun Login(onGo: (String, String, (String) -> Unit, (Boolean) -> Unit) -> Unit) {
    var user by remember { mutableStateOf("") }
    var pass by remember { mutableStateOf("") }
    var err by remember { mutableStateOf("") }
    var busy by remember { mutableStateOf(false) }
    val colors = OutlinedTextFieldDefaults.colors(
        focusedBorderColor = Ember,
        unfocusedBorderColor = Color(0x22FFFFFF),
        focusedTextColor = Color.White,
        unfocusedTextColor = Color.White,
    )
    Column(
        Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Image(painterResource(R.drawable.logo), null, Modifier.size(64.dp).clip(RoundedCornerShape(16.dp)))
        Spacer(Modifier.height(14.dp))
        Text("Welcome back.", color = Color.White, fontSize = 32.sp, fontWeight = FontWeight.Bold)
        Text("Only your servers. Only your account.", color = Muted)
        Spacer(Modifier.height(22.dp))
        OutlinedTextField(user, { user = it }, label = { Text("Email or username") }, modifier = Modifier.fillMaxWidth(), colors = colors, singleLine = true)
        Spacer(Modifier.height(10.dp))
        OutlinedTextField(pass, { pass = it }, label = { Text("Password") }, modifier = Modifier.fillMaxWidth(), colors = colors, singleLine = true, visualTransformation = PasswordVisualTransformation())
        Spacer(Modifier.height(8.dp))
        Text(err, color = Bad, fontSize = 13.sp, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(8.dp))
        Button(
            onClick = { onGo(user, pass, { err = it }, { busy = it }) },
            enabled = !busy && user.isNotBlank() && pass.isNotBlank(),
            modifier = Modifier.fillMaxWidth().height(52.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Ember, contentColor = Color(0xFF1A0709)),
            shape = RoundedCornerShape(14.dp),
        ) { Text(if (busy) "Signing in…" else "Sign in", fontWeight = FontWeight.Bold) }
    }
}

@Composable
private fun Home(
    email: String,
    servers: List<BlazeServer>,
    query: String,
    onQuery: (String) -> Unit,
    onOpen: (BlazeServer) -> Unit,
    onPower: (String, String) -> Unit,
    onLogout: () -> Unit,
    api: BlazeClient,
) {
    Column(Modifier.fillMaxSize().padding(horizontal = 16.dp, vertical = 28.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Image(painterResource(R.drawable.logo), null, Modifier.size(40.dp).clip(RoundedCornerShape(10.dp)))
            Spacer(Modifier.width(10.dp))
            Column(Modifier.weight(1f)) {
                Text("Blaze Hosting", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                Text(email, color = Muted, fontSize = 12.sp)
            }
            Box(
                Modifier.border(1.dp, Ember.copy(alpha = 0.45f), RoundedCornerShape(99.dp)).padding(horizontal = 10.dp, vertical = 4.dp),
            ) { Text("ISOLATED", color = EmberBright, fontSize = 10.sp, fontWeight = FontWeight.Bold) }
            TextButton(onClick = onLogout) { Text("Log out", color = Muted) }
        }
        Spacer(Modifier.height(14.dp))
        OutlinedTextField(
            query, onQuery, placeholder = { Text("Search servers") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = Ember, unfocusedBorderColor = Color(0x22FFFFFF), focusedTextColor = Color.White, unfocusedTextColor = Color.White),
            singleLine = true,
        )
        Spacer(Modifier.height(12.dp))
        LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp), contentPadding = PaddingValues(bottom = 40.dp)) {
            items(servers, key = { it.id }) { s ->
                ServerCard(s, api, onOpen, onPower)
            }
        }
    }
}

@Composable
private fun ServerCard(
    s: BlazeServer,
    api: BlazeClient,
    onOpen: (BlazeServer) -> Unit,
    onPower: (String, String) -> Unit,
) {
    var state by remember { mutableStateOf("…") }
    LaunchedEffect(s.id) {
        state = runCatching { api.resources(s.id).state }.getOrDefault("offline")
    }
    val orb = when (state) {
        "running" -> Ok
        "starting", "stopping" -> Color(0xFFF5C36E)
        else -> Bad
    }
    Column(
        Modifier.fillMaxWidth().clip(RoundedCornerShape(18.dp)).background(Card).border(1.dp, Color(0x14FFFFFF), RoundedCornerShape(18.dp)).clickable { onOpen(s) }.padding(16.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(10.dp).clip(CircleShape).background(orb))
            Spacer(Modifier.width(8.dp))
            Text(s.name, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 17.sp)
        }
        Text("${s.node} · ${s.memoryMb} MB RAM · $state", color = Muted, fontSize = 12.sp, modifier = Modifier.padding(top = 6.dp))
        Box(Modifier.padding(top = 10.dp).fillMaxWidth().height(6.dp).clip(RoundedCornerShape(99.dp)).background(Color(0xFF1F1F26))) {
            Box(Modifier.fillMaxWidth( (s.memoryMb / 2048f).coerceIn(0.08f, 1f) ).height(6.dp).background(Brush.horizontalGradient(listOf(Ember, EmberBright))))
        }
        Row(Modifier.padding(top = 12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            PowerChip("Start", Ok) { onPower(s.id, "start") }
            PowerChip("Restart", EmberBright) { onPower(s.id, "restart") }
            PowerChip("Stop", Bad) { onPower(s.id, "stop") }
        }
    }
}

@Composable
private fun PowerChip(label: String, color: Color, onClick: () -> Unit) {
    OutlinedButton(onClick = onClick, shape = RoundedCornerShape(12.dp), border = androidx.compose.foundation.BorderStroke(1.dp, color.copy(alpha = 0.4f))) {
        Text(label, color = color, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun ServerPage(server: BlazeServer, api: BlazeClient, onBack: () -> Unit) {
    val logs = remember { mutableStateListOf<String>() }
    var socket by remember { mutableStateOf<WebSocket?>(null) }
    val scope = rememberCoroutineScope()
    LaunchedEffect(server.id) {
        val ws = api.openConsole(server.id) { line -> logs.add(line); if (logs.size > 400) logs.removeAt(0) }
        socket = ws
    }
    DisposableEffect(server.id) {
        onDispose { socket?.cancel(); socket = null }
    }
    Column(Modifier.fillMaxSize().padding(16.dp, 28.dp)) {
        TextButton(onClick = onBack) { Text("← Servers", color = EmberBright, fontWeight = FontWeight.Bold) }
        Text(server.name, color = Color.White, fontSize = 24.sp, fontWeight = FontWeight.Bold)
        Text(server.id, color = Muted, fontSize = 12.sp)
        Row(Modifier.padding(vertical = 12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            PowerChip("Start", Ok) { scope.launch { runCatching { api.power(server.id, "start") } } }
            PowerChip("Restart", EmberBright) { scope.launch { runCatching { api.power(server.id, "restart") } } }
            PowerChip("Stop", Bad) { scope.launch { runCatching { api.power(server.id, "stop") } } }
        }
        val term = logs.joinToString("")
        Text(
            if (term.isBlank()) "Waiting for console…" else term,
            color = Color(0xFFD1D5DB),
            fontSize = 12.sp,
            fontFamily = FontFamily.Monospace,
            modifier = Modifier.fillMaxWidth().weight(1f).clip(RoundedCornerShape(14.dp)).background(Color(0xFF050506)).padding(12.dp).verticalScroll(rememberScrollState()),
        )
    }
}
