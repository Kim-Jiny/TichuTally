package com.tichutally.app.presentation.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import com.tichutally.app.data.GameHistoryEntry
import com.tichutally.app.presentation.ui.screen.GameScreen
import com.tichutally.app.presentation.ui.screen.RecordsScreen
import com.tichutally.app.presentation.ui.theme.TichuTallyTheme
import com.tichutally.app.presentation.viewmodel.GameViewModel
import com.tichutally.app.presentation.viewmodel.ThemeMode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class MainActivity : ComponentActivity() {

    // Compose의 viewModel()과 동일한 인스턴스 (액티비티 ViewModelStore 공유)
    private val gameViewModel: GameViewModel by viewModels()

    override fun onStop() {
        super.onStop()
        gameViewModel.flush()
    }

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

            var showRecords by remember { mutableStateOf(false) }

            TichuTallyTheme(darkTheme = darkTheme) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    if (showRecords) {
                        var history by remember { mutableStateOf(emptyList<GameHistoryEntry>()) }
                        LaunchedEffect(Unit) {
                            history = withContext(Dispatchers.IO) { viewModel.loadHistory() }
                        }
                        RecordsScreen(
                            history = history,
                            onBack = { showRecords = false },
                            onClearHistory = {
                                viewModel.clearHistory()
                                history = emptyList()
                            }
                        )
                    } else {
                        GameScreen(
                            viewModel = viewModel,
                            onOpenRecords = { showRecords = true }
                        )
                    }
                }
            }
        }
    }
}
