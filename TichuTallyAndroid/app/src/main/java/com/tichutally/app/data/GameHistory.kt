package com.tichutally.app.data

import com.tichutally.app.domain.model.Game
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.domain.model.TichuType
import kotlinx.serialization.Serializable

/** 완료(또는 종료)된 한 게임의 기록. 통계 계산을 위해 전체 게임 스냅샷을 보관한다. */
@Serializable
data class GameHistoryEntry(
    val completedAt: Long,
    val game: Game
) {
    val winner: TeamType? get() = game.winner
    val roundCount: Int get() = game.rounds.size
    val teamAScore: Int get() = game.teamA.totalScore
    val teamBScore: Int get() = game.teamB.totalScore
}

/** 기록으로부터 계산된 통계 요약. */
data class GameStats(
    val totalGames: Int,
    val teamAWins: Int,
    val teamBWins: Int,
    val draws: Int,
    val avgRounds: Double,
    val smallTichuAttempts: Int,
    val smallTichuSuccess: Int,
    val largeTichuAttempts: Int,
    val largeTichuSuccess: Int,
    val oneTwoFinishCount: Int,
    val highestScore: Int
) {
    val teamAWinRate: Double get() = if (totalGames == 0) 0.0 else teamAWins.toDouble() / totalGames
    val teamBWinRate: Double get() = if (totalGames == 0) 0.0 else teamBWins.toDouble() / totalGames
    val smallTichuRate: Double
        get() = if (smallTichuAttempts == 0) 0.0 else smallTichuSuccess.toDouble() / smallTichuAttempts
    val largeTichuRate: Double
        get() = if (largeTichuAttempts == 0) 0.0 else largeTichuSuccess.toDouble() / largeTichuAttempts

    companion object {
        fun from(entries: List<GameHistoryEntry>): GameStats {
            var teamAWins = 0
            var teamBWins = 0
            var draws = 0
            var totalRounds = 0
            var smallAtt = 0
            var smallSucc = 0
            var largeAtt = 0
            var largeSucc = 0
            var oneTwo = 0
            var highest = 0

            for (entry in entries) {
                when (entry.winner) {
                    TeamType.TEAM_A -> teamAWins++
                    TeamType.TEAM_B -> teamBWins++
                    null -> draws++
                }
                totalRounds += entry.roundCount
                highest = maxOf(highest, entry.teamAScore, entry.teamBScore)
                for (round in entry.game.rounds) {
                    if (round.isOneTwoFinish) oneTwo++
                    for (call in round.tichuCalls) {
                        when (call.type) {
                            TichuType.SMALL -> {
                                smallAtt++
                                if (call.isSuccess) smallSucc++
                            }
                            TichuType.LARGE -> {
                                largeAtt++
                                if (call.isSuccess) largeSucc++
                            }
                        }
                    }
                }
            }

            val total = entries.size
            return GameStats(
                totalGames = total,
                teamAWins = teamAWins,
                teamBWins = teamBWins,
                draws = draws,
                avgRounds = if (total == 0) 0.0 else totalRounds.toDouble() / total,
                smallTichuAttempts = smallAtt,
                smallTichuSuccess = smallSucc,
                largeTichuAttempts = largeAtt,
                largeTichuSuccess = largeSucc,
                oneTwoFinishCount = oneTwo,
                highestScore = highest
            )
        }
    }
}
