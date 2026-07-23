package com.tichutally.app.data

import android.content.Context
import com.tichutally.app.presentation.viewmodel.GameState
import kotlinx.serialization.json.Json
import java.io.File

/**
 * 진행 중인 게임 상태를 내부 저장소에 JSON으로 영속화한다.
 * 프로세스가 종료돼도 앱 재실행 시 게임을 이어갈 수 있게 한다.
 */
class GameStorage(context: Context) {

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
        // Map<Player, _> 처럼 클래스 키를 가진 맵을 [key, value, ...] 배열로 직렬화
        allowStructuredMapKeys = true
    }

    private val file: File = File(context.filesDir, FILE_NAME)

    fun save(state: GameState) {
        runCatching {
            file.writeText(json.encodeToString(GameState.serializer(), state))
        }.onFailure { android.util.Log.e("GameStorage", "save failed", it) }
    }

    fun load(): GameState? {
        return runCatching {
            if (!file.exists()) return null
            json.decodeFromString(GameState.serializer(), file.readText())
        }.getOrNull()
    }

    companion object {
        private const val FILE_NAME = "current_game.json"
    }
}
