package com.tichutally.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Player(
    val team: TeamType,
    val position: Int  // 0 or 1
) {
    val displayName: String
        get() = "${team.shortName}${position + 1}"

    companion object {
        val allPlayers = listOf(
            Player(TeamType.TEAM_A, 0),
            Player(TeamType.TEAM_A, 1),
            Player(TeamType.TEAM_B, 0),
            Player(TeamType.TEAM_B, 1)
        )
    }
}
