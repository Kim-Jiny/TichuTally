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
            // 원투피니시 시 상대팀은 1등이 불가능하므로 티추 성공을 강제로 실패 처리
            val oneTwoOpponent = if (currentState.currentOneTwoFinish)
                currentState.currentOneTwoFinishTeam?.opponent else null
            val tichuCalls = currentState.currentTichuCalls.mapNotNull { (player, input) ->
                input.type?.let { type ->
                    val success = if (player.team == oneTwoOpponent) false else input.isSuccess
                    TichuCall(player, type, success)
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

    fun setTargetScore(score: Int) {
        _state.update { currentState ->
            val wasOver = currentState.game.isGameOver
            val newGame = currentState.game.copy(targetScore = score)
            // 게임이 새로 종료된 경우에만 승자 다이얼로그 노출.
            // 이미 종료돼 있었다면 기존 노출 상태 유지(닫아둔 걸 다시 띄우지 않음), 해제되면 숨김.
            val showWinner = newGame.isGameOver && (currentState.showWinnerDialog || !wasOver)
            currentState.copy(
                targetScore = score,
                game = newGame,
                showWinnerDialog = showWinner
            )
        }
    }

    fun setThemeMode(mode: ThemeMode) {
        _state.update { it.copy(themeMode = mode) }
    }

    fun newGame() {
        _state.update { currentState ->
            GameState(
                targetScore = currentState.targetScore,
                themeMode = currentState.themeMode,
                game = Game(targetScore = currentState.targetScore)
            )
        }
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
