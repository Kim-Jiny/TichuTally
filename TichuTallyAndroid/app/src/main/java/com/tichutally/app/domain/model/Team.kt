package com.tichutally.app.domain.model

enum class TeamType(val shortName: String) {
    TEAM_A("A"),
    TEAM_B("B");

    val opponent: TeamType
        get() = when (this) {
            TEAM_A -> TEAM_B
            TEAM_B -> TEAM_A
        }
}

data class Team(
    val type: TeamType,
    val totalScore: Int = 0
)
