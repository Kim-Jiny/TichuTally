package com.tichutally.app.presentation.ui

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
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
    private companion object {
        const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // AdMob 가족용 광고 설정 (Google Play 가족 정책 준수)
        val requestConfiguration = RequestConfiguration.Builder()
            .setMaxAdContentRating(RequestConfiguration.MAX_AD_CONTENT_RATING_G)
            .setTagForChildDirectedTreatment(RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE)
            .build()
        MobileAds.setRequestConfiguration(requestConfiguration)

        // AdMob 초기화 - 어댑터 상태 로깅으로 초기화 실패 진단 가능
        MobileAds.initialize(this) { initializationStatus ->
            val statusMap = initializationStatus.adapterStatusMap
            if (statusMap.isEmpty()) {
                Log.e(TAG, "AdMob 초기화 실패: 어댑터 상태가 비어 있습니다.")
            } else {
                statusMap.forEach { (adapterClass, status) ->
                    Log.d(
                        TAG,
                        "AdMob 어댑터 $adapterClass: ${status.initializationState} (${status.description})"
                    )
                }
            }
        }

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
