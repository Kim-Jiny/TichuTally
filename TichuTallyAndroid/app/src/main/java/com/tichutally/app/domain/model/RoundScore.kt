package com.tichutally.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class RoundScore(
    val teamAScore: Int,
    val teamBScore: Int
) {
    val teamADisplay: String
        get() = if (teamAScore >= 0) "+$teamAScore" else "$teamAScore"

    val teamBDisplay: String
        get() = if (teamBScore >= 0) "+$teamBScore" else "$teamBScore"
}
