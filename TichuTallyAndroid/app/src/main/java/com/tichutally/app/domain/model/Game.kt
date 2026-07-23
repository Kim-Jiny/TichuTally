package com.tichutally.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Game(
    val teamA: Team = Team(TeamType.TEAM_A),
    val teamB: Team = Team(TeamType.TEAM_B),
    val rounds: List<Round> = emptyList(),
    val targetScore: Int = 1000
) {
    val winner: TeamType?
        get() = when {
            teamA.totalScore >= targetScore && teamA.totalScore > teamB.totalScore -> TeamType.TEAM_A
            teamB.totalScore >= targetScore && teamB.totalScore > teamA.totalScore -> TeamType.TEAM_B
            else -> null
        }

    val isGameOver: Boolean
        get() = winner != null
}
