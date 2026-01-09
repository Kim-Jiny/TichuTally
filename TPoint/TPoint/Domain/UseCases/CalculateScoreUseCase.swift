//
//  CalculateScoreUseCase.swift
//  TPoint
//

import Foundation

struct RoundScore {
    let teamAScore: Int
    let teamBScore: Int

    var teamADisplay: String {
        teamAScore >= 0 ? "+\(teamAScore)" : "\(teamAScore)"
    }

    var teamBDisplay: String {
        teamBScore >= 0 ? "+\(teamBScore)" : "\(teamBScore)"
    }
}

protocol CalculateScoreUseCaseProtocol {
    func calculate(round: Round) -> RoundScore
}

final class CalculateScoreUseCase: CalculateScoreUseCaseProtocol {

    func calculate(round: Round) -> RoundScore {
        var teamAScore = 0
        var teamBScore = 0

        // 1. 카드 점수 계산 (원투 피니시 여부에 따라)
        if round.isOneTwoFinish, let winningTeam = round.oneTwoFinishTeam {
            // 원투 피니시: 승리 팀 200점, 상대팀 0점
            switch winningTeam {
            case .teamA:
                teamAScore = 200
                teamBScore = 0
            case .teamB:
                teamAScore = 0
                teamBScore = 200
            }
        } else {
            // 일반 경우: 카드 점수 그대로
            teamAScore = round.teamACardScore
            teamBScore = round.teamBCardScore
        }

        // 2. 티츄 보너스/패널티 계산
        for call in round.tichuCalls {
            let points = call.points
            switch call.player.team {
            case .teamA:
                teamAScore += points
            case .teamB:
                teamBScore += points
            }
        }

        return RoundScore(teamAScore: teamAScore, teamBScore: teamBScore)
    }
}
