//
//  Player.swift
//  TPoint
//

import Foundation

struct Player: Hashable, Codable {
    let team: TeamType
    let position: Int  // 0 or 1 (팀 내 순서)

    var displayName: String {
        "\(team.shortName)\(position + 1)"
    }

    static let allPlayers: [Player] = [
        Player(team: .teamA, position: 0),
        Player(team: .teamA, position: 1),
        Player(team: .teamB, position: 0),
        Player(team: .teamB, position: 1)
    ]
}
