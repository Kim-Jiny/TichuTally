package com.tichutally.app.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tichutally.app.data.GameHistoryEntry
import com.tichutally.app.data.GameStorage
import com.tichutally.app.data.HistoryStorage
import com.tichutally.app.domain.model.*
import com.tichutally.app.domain.usecase.CalculateScoreUseCase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class GameViewModel(application: Application) : AndroidViewModel(application) {

    private val calculateScoreUseCase = CalculateScoreUseCase()
    private val storage = GameStorage(application)
    private val historyStorage = HistoryStorage(application)

    // 저장된 진행 중 게임이 있으면 복원, 없으면 새 게임으로 시작
    private val _state = MutableStateFlow(storage.load() ?: GameState())
    val state: StateFlow<GameState> = _state.asStateFlow()

    @OptIn(FlowPreview::class)
    private val autoSave = viewModelScope.launch(Dispatchers.IO) {
        // 상태 변경 시 자동 저장 (연속 슬라이더 입력은 디바운스로 합침)
        state.drop(1).debounce(250).collect { storage.save(it) }
    }

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

    fun setTeamNames(teamAName: String, teamBName: String) {
        _state.update { it.copy(teamAName = teamAName.trim(), teamBName = teamBName.trim()) }
    }

    fun newGame() {
        // 라운드가 있는 현재 게임은 새 게임 시작 시 기록에 보관
        val current = _state.value
        if (current.game.rounds.isNotEmpty()) {
            val entry = GameHistoryEntry(System.currentTimeMillis(), current.game)
            viewModelScope.launch(Dispatchers.IO) { historyStorage.append(entry) }
        }
        _state.update { currentState ->
            GameState(
                targetScore = currentState.targetScore,
                themeMode = currentState.themeMode,
                teamAName = currentState.teamAName,
                teamBName = currentState.teamBName,
                game = Game(targetScore = currentState.targetScore)
            )
        }
    }

    fun loadHistory(): List<GameHistoryEntry> = historyStorage.load()

    fun clearHistory() {
        viewModelScope.launch(Dispatchers.IO) { historyStorage.clear() }
    }

    fun updateRound(
        index: Int,
        teamACardScore: Int,
        isOneTwoFinish: Boolean,
        oneTwoFinishTeam: TeamType?,
        tichuCalls: Map<Player, TichuCallInput>
    ) {
        _state.update { currentState ->
            val rounds = currentState.game.rounds
            if (index < 0 || index >= rounds.size) return@update currentState
            val oldScore = currentState.roundScores.getOrNull(index) ?: return@update currentState

            // 원투피니시 시 상대팀 티추 성공 강제 실패
            val oneTwoOpponent = if (isOneTwoFinish) oneTwoFinishTeam?.opponent else null
            val calls = tichuCalls.mapNotNull { (player, input) ->
                input.type?.let { type ->
                    val success = if (player.team == oneTwoOpponent) false else input.isSuccess
                    TichuCall(player, type, success)
                }
            }
            val newRound = rounds[index].copy(
                teamACardScore = teamACardScore.coerceIn(-25, 125),
                isOneTwoFinish = isOneTwoFinish,
                oneTwoFinishTeam = oneTwoFinishTeam,
                tichuCalls = calls
            )
            val newScore = calculateScoreUseCase.calculate(newRound)

            val newRounds = rounds.toMutableList().apply { set(index, newRound) }
            val newRoundScores = currentState.roundScores.toMutableList().apply { set(index, newScore) }
            val newTeamA = currentState.game.teamA.copy(
                totalScore = currentState.game.teamA.totalScore - oldScore.teamAScore + newScore.teamAScore
            )
            val newTeamB = currentState.game.teamB.copy(
                totalScore = currentState.game.teamB.totalScore - oldScore.teamBScore + newScore.teamBScore
            )
            val wasOver = currentState.game.isGameOver
            val newGame = currentState.game.copy(teamA = newTeamA, teamB = newTeamB, rounds = newRounds)
            currentState.copy(
                game = newGame,
                roundScores = newRoundScores,
                showWinnerDialog = newGame.isGameOver && (currentState.showWinnerDialog || !wasOver)
            )
        }
    }

    // 삭제 직전 상태 (실행취소용)
    private var undoSnapshot: GameState? = null

    fun deleteRound(index: Int) {
        val pre = _state.value
        val rounds = pre.game.rounds
        if (index < 0 || index >= rounds.size) return
        val deletedScore = pre.roundScores.getOrNull(index) ?: return

        // 실행취소를 위해 삭제 직전 상태 보관 (플래그는 제외)
        undoSnapshot = pre.copy(showUndoDelete = false)

        val newTeamA = pre.game.teamA.copy(totalScore = pre.game.teamA.totalScore - deletedScore.teamAScore)
        val newTeamB = pre.game.teamB.copy(totalScore = pre.game.teamB.totalScore - deletedScore.teamBScore)

        // 라운드 삭제 및 번호 재정렬
        val newRounds = rounds.toMutableList().apply { removeAt(index) }
            .mapIndexed { i, round -> round.copy(roundNumber = i + 1) }
        val newRoundScores = pre.roundScores.toMutableList().apply { removeAt(index) }

        _state.value = pre.copy(
            game = pre.game.copy(teamA = newTeamA, teamB = newTeamB, rounds = newRounds),
            roundScores = newRoundScores,
            showWinnerDialog = false,
            showUndoDelete = true
        )
    }

    fun undoDelete() {
        undoSnapshot?.let { _state.value = it }
        undoSnapshot = null
    }

    fun dismissUndo() {
        undoSnapshot = null
        _state.update { it.copy(showUndoDelete = false) }
    }
}
