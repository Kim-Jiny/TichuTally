package com.tichutally.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
enum class TichuType {
    SMALL,  // 100 points
    LARGE   // 200 points
}

@Serializable
data class TichuCall(
    val player: Player,
    val type: TichuType,
    val isSuccess: Boolean
) {
    val points: Int
        get() {
            val basePoints = if (type == TichuType.LARGE) 200 else 100
            return if (isSuccess) basePoints else -basePoints
        }
}
