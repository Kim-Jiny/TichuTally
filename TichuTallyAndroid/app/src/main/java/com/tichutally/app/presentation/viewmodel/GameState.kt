package com.tichutally.app.presentation.viewmodel

import com.tichutally.app.domain.model.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient

@Serializable
enum class ThemeMode {
    SYSTEM, LIGHT, DARK
}

@Serializable
data class TichuCallInput(
    val type: TichuType?,
    val isSuccess: Boolean = false
)

@Serializable
data class GameState(
    val game: Game = Game(),
    val currentTeamACardScore: Int = 50,
    val currentOneTwoFinish: Boolean = false,
    val currentOneTwoFinishTeam: TeamType? = null,
    val currentTichuCalls: Map<Player, TichuCallInput> = emptyMap(),
    val roundScores: List<RoundScore> = emptyList(),
    @Transient val showWinnerDialog: Boolean = false,
    val targetScore: Int = 1000,
    val themeMode: ThemeMode = ThemeMode.SYSTEM,
    // 사용자 지정 팀 이름 (빈 문자열이면 기본 리소스 이름 사용)
    val teamAName: String = "",
    val teamBName: String = ""
) {
    val teamAScore: Int get() = game.teamA.totalScore
    val teamBScore: Int get() = game.teamB.totalScore
    val rounds: List<Round> get() = game.rounds
    val isGameOver: Boolean get() = game.isGameOver
    val winner: TeamType? get() = game.winner
    val currentTeamBCardScore: Int get() = 100 - currentTeamACardScore
    val currentRound: Int get() = game.rounds.size + 1
}
