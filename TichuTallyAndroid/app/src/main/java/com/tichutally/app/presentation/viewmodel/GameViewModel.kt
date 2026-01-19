package com.tichutally.app.presentation.viewmodel

import androidx.lifecycle.ViewModel
import com.tichutally.app.domain.model.*
import com.tichutally.app.domain.usecase.CalculateScoreUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class GameViewModel(
    private val calculateScoreUseCase: CalculateScoreUseCase = CalculateScoreUseCase()
) : ViewModel() {

    private val _state = MutableStateFlow(GameState())
    val state: StateFlow<GameState> = _state.asStateFlow()

    fun setTeamACardScore(score: Int) {
        _state.update { it.copy(currentTeamACardScore = score.coerceIn(-25, 125)) }
    }

    fun setOneTwoFinish(enabled: Boolean, team: TeamType?) {
        _state.update {
            it.copy(
                currentOneTwoFinish = enabled,
                currentOneTwoFinishTeam = team
            )
        }
    }

    fun setTichuCall(player: Player, type: TichuType?, isSuccess: Boolean) {
        _state.update { currentState ->
            val newCalls = currentState.currentTichuCalls.toMutableMap()

            if (type != null) {
                newCalls[player] = TichuCallInput(type, isSuccess)

                // Auto-fail other tichu calls when one succeeds
                if (isSuccess) {
                    Player.allPlayers.filter { it != player }.forEach { otherPlayer ->
                        newCalls[otherPlayer]?.let { call ->
                            if (call.type != null) {
                                newCalls[otherPlayer] = call.copy(isSuccess = false)
                            }
                        }
                    }
                }
            } else {
                newCalls.remove(player)
            }

            currentState.copy(currentTichuCalls = newCalls)
        }
    }

    fun addRound() {
        _state.update { currentState ->
            val tichuCalls = currentState.currentTichuCalls.mapNotNull { (player, input) ->
                input.type?.let { type ->
                    TichuCall(player, type, input.isSuccess)
                }
            }

            val round = Round(
                roundNumber = currentState.game.rounds.size + 1,
                teamACardScore = currentState.currentTeamACardScore,
                isOneTwoFinish = currentState.currentOneTwoFinish,
                oneTwoFinishTeam = currentState.currentOneTwoFinishTeam,
                tichuCalls = tichuCalls
            )

            val score = calculateScoreUseCase.calculate(round)

            val newGame = currentState.game.copy(
                teamA = currentState.game.teamA.copy(
                    totalScore = currentState.game.teamA.totalScore + score.teamAScore
                ),
                teamB = currentState.game.teamB.copy(
                    totalScore = currentState.game.teamB.totalScore + score.teamBScore
                ),
                rounds = currentState.game.rounds + round
            )

            val newRoundScores = currentState.roundScores + score

            currentState.copy(
                game = newGame,
                roundScores = newRoundScores,
                currentTeamACardScore = 50,
                currentOneTwoFinish = false,
                currentOneTwoFinishTeam = null,
                currentTichuCalls = emptyMap(),
                showWinnerDialog = newGame.isGameOver
            )
        }
    }

    fun dismissWinnerDialog() {
        _state.update { it.copy(showWinnerDialog = false) }
    }

    fun newGame() {
        _state.value = GameState()
    }

    fun deleteRound(index: Int) {
        _state.update { currentState ->
            val rounds = currentState.game.rounds
            if (index < 0 || index >= rounds.size) return@update currentState

            val deletedScore = currentState.roundScores.getOrNull(index) ?: return@update currentState

            // 점수 차감
            val newTeamA = currentState.game.teamA.copy(
                totalScore = currentState.game.teamA.totalScore - deletedScore.teamAScore
            )
            val newTeamB = currentState.game.teamB.copy(
                totalScore = currentState.game.teamB.totalScore - deletedScore.teamBScore
            )

            // 라운드 삭제 및 번호 재정렬
            val newRounds = rounds.toMutableList().apply { removeAt(index) }
                .mapIndexed { i, round -> round.copy(roundNumber = i + 1) }

            val newRoundScores = currentState.roundScores.toMutableList().apply { removeAt(index) }

            currentState.copy(
                game = currentState.game.copy(
                    teamA = newTeamA,
                    teamB = newTeamB,
                    rounds = newRounds
                ),
                roundScores = newRoundScores,
                showWinnerDialog = false
            )
        }
    }
}
