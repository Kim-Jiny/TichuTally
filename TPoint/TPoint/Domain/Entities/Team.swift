//
//  Team.swift
//  TPoint
//

import Foundation

enum TeamType: String, CaseIterable {
    case teamA = "A"
    case teamB = "B"

    var displayName: String {
        switch self {
        case .teamA: return L10n.teamA
        case .teamB: return L10n.teamB
        }
    }

    var shortName: String {
        rawValue
    }

    var opponent: TeamType {
        switch self {
        case .teamA: return .teamB
        case .teamB: return .teamA
        }
    }
}

struct Team {
    let type: TeamType
    var totalScore: Int = 0

    var displayName: String {
        type.displayName
    }
}
