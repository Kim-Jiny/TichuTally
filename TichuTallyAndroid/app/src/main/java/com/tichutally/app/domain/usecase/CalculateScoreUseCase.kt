package com.tichutally.app.domain.usecase

import com.tichutally.app.domain.model.Round
import com.tichutally.app.domain.model.RoundScore
import com.tichutally.app.domain.model.TeamType

class CalculateScoreUseCase {

    fun calculate(round: Round): RoundScore {
        var teamAScore: Int
        var teamBScore: Int

        // 1. Card score calculation (based on one-two finish)
        if (round.isOneTwoFinish && round.oneTwoFinishTeam != null) {
            when (round.oneTwoFinishTeam) {
                TeamType.TEAM_A -> {
                    teamAScore = 200
                    teamBScore = 0
                }
                TeamType.TEAM_B -> {
                    teamAScore = 0
                    teamBScore = 200
                }
            }
        } else {
            teamAScore = round.teamACardScore
            teamBScore = round.teamBCardScore
        }

        // 2. Tichu bonus/penalty calculation
        for (call in round.tichuCalls) {
            when (call.player.team) {
                TeamType.TEAM_A -> teamAScore += call.points
                TeamType.TEAM_B -> teamBScore += call.points
            }
        }

        return RoundScore(teamAScore, teamBScore)
    }
}
