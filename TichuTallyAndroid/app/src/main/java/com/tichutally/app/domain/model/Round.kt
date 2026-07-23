package com.tichutally.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Round(
    val roundNumber: Int,
    val teamACardScore: Int = 50,
    val isOneTwoFinish: Boolean = false,
    val oneTwoFinishTeam: TeamType? = null,
    val tichuCalls: List<TichuCall> = emptyList()
) {
    val teamBCardScore: Int
        get() = 100 - teamACardScore
}
