package com.tichutally.app.presentation.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import com.tichutally.app.presentation.ui.screen.GameScreen
import com.tichutally.app.presentation.ui.theme.TichuTallyTheme
import com.tichutally.app.presentation.viewmodel.GameViewModel
import com.tichutally.app.presentation.viewmodel.ThemeMode

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 모든 API 레벨에서 일관된 edge-to-edge 처리 (targetSdk 35+ 강제 대응)
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        // AdMob 가족용 광고 설정 (Google Play 가족 정책 준수)
        val requestConfiguration = RequestConfiguration.Builder()
            .setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_G)
            .setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE)
            .build()
        MobileAds.setRequestConfiguration(requestConfiguration)

        // AdMob 초기화
        MobileAds.initialize(this) {}

        setContent {
            val viewModel: GameViewModel = viewModel()
            val state by viewModel.state.collectAsState()

            val darkTheme = when (state.themeMode) {
                ThemeMode.SYSTEM -> isSystemInDarkTheme()
                ThemeMode.LIGHT -> false
                ThemeMode.DARK -> true
            }

            TichuTallyTheme(darkTheme = darkTheme) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    GameScreen(viewModel = viewModel)
                }
            }
        }
    }
}
