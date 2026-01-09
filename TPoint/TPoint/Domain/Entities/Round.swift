//
//  Round.swift
//  TPoint
//

import Foundation

struct TichuCall: Hashable {
    let player: Player
    let isLarge: Bool  // true: 라지티츄(200), false: 스몰티츄(100)
    var isSuccess: Bool

    var points: Int {
        let basePoints = isLarge ? 200 : 100
        return isSuccess ? basePoints : -basePoints
    }

    var displayName: String {
        isLarge ? L10n.largeTichu : L10n.smallTichu
    }
}

struct Round {
    let roundNumber: Int
    var teamACardScore: Int
    var isOneTwoFinish: Bool
    var oneTwoFinishTeam: TeamType?
    var tichuCalls: [TichuCall]

    var teamBCardScore: Int {
        100 - teamACardScore
    }

    init(roundNumber: Int,
         teamACardScore: Int = 50,
         isOneTwoFinish: Bool = false,
         oneTwoFinishTeam: TeamType? = nil,
         tichuCalls: [TichuCall] = []) {
        self.roundNumber = roundNumber
        self.teamACardScore = teamACardScore
        self.isOneTwoFinish = isOneTwoFinish
        self.oneTwoFinishTeam = oneTwoFinishTeam
        self.tichuCalls = tichuCalls
    }
}
