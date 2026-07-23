//
//  Game.swift
//  TPoint
//

import Foundation

struct Game: Codable {
    var teamA: Team
    var teamB: Team
    var rounds: [Round]
    var targetScore: Int

    init(targetScore: Int = 1000) {
        self.teamA = Team(type: .teamA)
        self.teamB = Team(type: .teamB)
        self.rounds = []
        self.targetScore = targetScore
    }

    var winner: TeamType? {
        if teamA.totalScore >= targetScore && teamA.totalScore > teamB.totalScore {
            return .teamA
        } else if teamB.totalScore >= targetScore && teamB.totalScore > teamA.totalScore {
            return .teamB
        }
        return nil
    }

    var isGameOver: Bool {
        winner != nil
    }

    mutating func reset() {
        teamA = Team(type: .teamA)
        teamB = Team(type: .teamB)
        rounds = []
    }
}
