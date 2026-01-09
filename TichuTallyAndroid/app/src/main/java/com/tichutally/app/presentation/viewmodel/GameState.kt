package com.tichutally.app.presentation.viewmodel

import com.tichutally.app.domain.model.*

data class TichuCallInput(
    val type: TichuType?,
    val isSuccess: Boolean = false
)

data class GameState(
    val game: Game = Game(),
    val currentTeamACardScore: Int = 50,
    val currentOneTwoFinish: Boolean = false,
    val currentOneTwoFinishTeam: TeamType? = null,
    val currentTichuCalls: Map<Player, TichuCallInput> = emptyMap(),
    val roundScores: List<RoundScore> = emptyList(),
    val showWinnerDialog: Boolean = false
) {
    val teamAScore: Int get() = game.teamA.totalScore
    val teamBScore: Int get() = game.teamB.totalScore
    val rounds: List<Round> get() = game.rounds
    val isGameOver: Boolean get() = game.isGameOver
    val winner: TeamType? get() = game.winner
    val currentTeamBCardScore: Int get() = 100 - currentTeamACardScore
}
