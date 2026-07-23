//
//  GameHistory.swift
//  TPoint
//
//  완료된 게임 기록과 통계 계산.
//

import Foundation

/// 완료(또는 종료)된 한 게임의 기록. 통계 계산을 위해 전체 게임 스냅샷을 보관한다.
struct GameHistoryEntry: Codable {
    let completedAt: Date
    let game: Game

    var winner: TeamType? { game.winner }
    var roundCount: Int { game.rounds.count }
    var teamAScore: Int { game.teamA.totalScore }
    var teamBScore: Int { game.teamB.totalScore }
}

/// 기록으로부터 계산된 통계 요약.
struct GameStats {
    let totalGames: Int
    let teamAWins: Int
    let teamBWins: Int
    let draws: Int
    let avgRounds: Double
    let smallTichuAttempts: Int
    let smallTichuSuccess: Int
    let largeTichuAttempts: Int
    let largeTichuSuccess: Int
    let oneTwoFinishCount: Int
    let highestScore: Int

    var teamAWinRate: Double { totalGames == 0 ? 0 : Double(teamAWins) / Double(totalGames) }
    var teamBWinRate: Double { totalGames == 0 ? 0 : Double(teamBWins) / Double(totalGames) }
    var smallTichuRate: Double { smallTichuAttempts == 0 ? 0 : Double(smallTichuSuccess) / Double(smallTichuAttempts) }
    var largeTichuRate: Double { largeTichuAttempts == 0 ? 0 : Double(largeTichuSuccess) / Double(largeTichuAttempts) }

    static func from(_ entries: [GameHistoryEntry]) -> GameStats {
        var teamAWins = 0, teamBWins = 0, draws = 0, totalRounds = 0
        var smallAtt = 0, smallSucc = 0, largeAtt = 0, largeSucc = 0
        var oneTwo = 0, highest = 0

        for entry in entries {
            switch entry.winner {
            case .teamA: teamAWins += 1
            case .teamB: teamBWins += 1
            case .none: draws += 1
            }
            totalRounds += entry.roundCount
            highest = max(highest, entry.teamAScore, entry.teamBScore)
            for round in entry.game.rounds {
                if round.isOneTwoFinish { oneTwo += 1 }
                for call in round.tichuCalls {
                    if call.isLarge {
                        largeAtt += 1
                        if call.isSuccess { largeSucc += 1 }
                    } else {
                        smallAtt += 1
                        if call.isSuccess { smallSucc += 1 }
                    }
                }
            }
        }

        let total = entries.count
        return GameStats(
            totalGames: total,
            teamAWins: teamAWins,
            teamBWins: teamBWins,
            draws: draws,
            avgRounds: total == 0 ? 0 : Double(totalRounds) / Double(total),
            smallTichuAttempts: smallAtt,
            smallTichuSuccess: smallSucc,
            largeTichuAttempts: largeAtt,
            largeTichuSuccess: largeSucc,
            oneTwoFinishCount: oneTwo,
            highestScore: highest
        )
    }
}
