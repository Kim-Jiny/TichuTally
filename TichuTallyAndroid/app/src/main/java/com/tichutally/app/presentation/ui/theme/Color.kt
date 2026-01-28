package com.tichutally.app.presentation.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

val Purple80 = Color(0xFFD0BCFF)
val PurpleGrey80 = Color(0xFFCCC2DC)
val Pink80 = Color(0xFFEFB8C8)

val Purple40 = Color(0xFF6650a4)
val PurpleGrey40 = Color(0xFF625b71)
val Pink40 = Color(0xFF7D5260)

// Team Colors
val TeamAColor = Color(0xFF2196F3)
val TeamAColorLight = Color(0xFFE3F2FD)
val TeamAColorMedium = Color(0xFFBBDEFB)
val TeamAColorDark = Color(0xFF1565C0)
val TeamAColorDarkLight = Color(0xFF1E3A5F)
val TeamAColorDarkMedium = Color(0xFF0D47A1)

val TeamBColor = Color(0xFFE53935)
val TeamBColorLight = Color(0xFFFFEBEE)
val TeamBColorMedium = Color(0xFFFFCDD2)
val TeamBColorDark = Color(0xFFB71C1C)
val TeamBColorDarkLight = Color(0xFF5F1E1E)
val TeamBColorDarkMedium = Color(0xFF7F1D1D)

// UI Colors
val SuccessColor = Color(0xFF43A047)
val SuccessColorLight = Color(0xFFE8F5E9)
val FailureColor = Color(0xFFE53935)

// Large Tichu
val LargeTichuColor = Color(0xFFFF9800)
val LargeTichuColorLight = Color(0xFFFFF3E0)

// App Colors data class for theming
data class AppColors(
    val teamAColor: Color,
    val teamAColorLight: Color,
    val teamAColorMedium: Color,
    val teamBColor: Color,
    val teamBColorLight: Color,
    val teamBColorMedium: Color,
    val successColor: Color,
    val failureColor: Color,
    val largeTichuColor: Color,
    val cardBackground: Color,
    val cardBackgroundElevated: Color,
    val surfaceLight: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val textHint: Color,
    val sliderTrackColor: Color
)

val LightAppColors = AppColors(
    teamAColor = TeamAColor,
    teamAColorLight = TeamAColorLight,
    teamAColorMedium = TeamAColorMedium,
    teamBColor = TeamBColor,
    teamBColorLight = TeamBColorLight,
    teamBColorMedium = TeamBColorMedium,
    successColor = SuccessColor,
    failureColor = FailureColor,
    largeTichuColor = LargeTichuColor,
    cardBackground = Color(0xFFFAFAFA),
    cardBackgroundElevated = Color(0xFFFFFFFF),
    surfaceLight = Color(0xFFF5F5F5),
    textPrimary = Color(0xFF212121),
    textSecondary = Color(0xFF757575),
    textHint = Color(0xFFBDBDBD),
    sliderTrackColor = Color(0xFFE0E0E0)
)

val DarkAppColors = AppColors(
    teamAColor = Color(0xFF64B5F6),
    teamAColorLight = Color(0xFF0D1F33),
    teamAColorMedium = Color(0xFF1565C0),
    teamBColor = Color(0xFFEF5350),
    teamBColorLight = Color(0xFF330D0D),
    teamBColorMedium = Color(0xFFB71C1C),
    successColor = Color(0xFF66BB6A),
    failureColor = Color(0xFFEF5350),
    largeTichuColor = Color(0xFFFFB74D),
    cardBackground = Color(0xFF1A1A1A),
    cardBackgroundElevated = Color(0xFF242424),
    surfaceLight = Color(0xFF0D0D0D),
    textPrimary = Color(0xFFE8E8E8),
    textSecondary = Color(0xFF9E9E9E),
    textHint = Color(0xFF5A5A5A),
    sliderTrackColor = Color(0xFF3A3A3A)
)

val LocalAppColors = staticCompositionLocalOf { LightAppColors }

// Legacy color references for backward compatibility
val CardBackground = Color(0xFFFAFAFA)
val CardBackgroundElevated = Color(0xFFFFFFFF)
val SurfaceLight = Color(0xFFF5F5F5)
val SliderTrackColor = Color(0xFFE0E0E0)
val SliderActiveTrackA = Color(0xFF2196F3)
val SliderActiveTrackB = Color(0xFFE53935)
val TextPrimary = Color(0xFF212121)
val TextSecondary = Color(0xFF757575)
val TextHint = Color(0xFFBDBDBD)
