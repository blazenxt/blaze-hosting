package com.blazenxt.hosting.ui

import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val Ember = Color(0xFFC94F59)
val EmberBright = Color(0xFFF08A90)
val Bg = Color(0xFF070708)
val Panel = Color(0xFF101014)
val Card = Color(0xFF16161C)
val Muted = Color(0xFF8B8794)
val Ok = Color(0xFF5EE9A8)
val Bad = Color(0xFFFB7185)

@Composable
fun BlazeTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = Ember,
            onPrimary = Color(0xFF1A0709),
            background = Bg,
            surface = Panel,
            onBackground = Color(0xFFF5F4F8),
            onSurface = Color(0xFFF5F4F8),
            secondary = EmberBright,
        ),
        content = content,
    )
}
