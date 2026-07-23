package com.tichutally.app.data

import android.content.Context
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.json.Json
import java.io.File

/** 완료된 게임 기록 목록을 내부 저장소에 JSON으로 보관한다. */
class HistoryStorage(context: Context) {

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
        allowStructuredMapKeys = true
    }

    private val serializer = ListSerializer(GameHistoryEntry.serializer())
    private val file = File(context.filesDir, FILE_NAME)

    /** 최신순으로 정렬된 기록 목록을 반환한다. */
    fun load(): List<GameHistoryEntry> = runCatching {
        if (!file.exists()) return emptyList()
        json.decodeFromString(serializer, file.readText())
            .sortedByDescending { it.completedAt }
    }.getOrDefault(emptyList())

    fun append(entry: GameHistoryEntry) {
        val updated = (load() + entry).sortedByDescending { it.completedAt }
        save(updated)
    }

    fun clear() {
        runCatching { file.delete() }
    }

    private fun save(entries: List<GameHistoryEntry>) {
        runCatching {
            file.writeText(json.encodeToString(serializer, entries))
        }
    }

    companion object {
        private const val FILE_NAME = "history.json"
    }
}
