//
//  PersistenceTests.swift
//  TPointTests
//
//  게임 자동 저장/복원(영속화) 검증
//

import Testing
import Foundation
@testable import TPoint

struct PersistenceTests {

    /// GameSnapshot(딕셔너리 키가 Player 구조체 포함)이 JSON 왕복에서 손실 없이 복원되는지
    @Test func snapshotRoundTrips() throws {
        var game = Game(targetScore: 500)
        game.teamA.totalScore = 120
        game.teamB.totalScore = 80
        game.rounds = [
            Round(roundNumber: 1,
                  teamACardScore: -25,
                  isOneTwoFinish: false,
                  oneTwoFinishTeam: nil,
                  tichuCalls: [TichuCall(player: Player(team: .teamA, position: 0),
                                         isLarge: true, isSuccess: true)]),
            Round(roundNumber: 2,
                  teamACardScore: 100,
                  isOneTwoFinish: true,
                  oneTwoFinishTeam: .teamB,
                  tichuCalls: [])
        ]
        let calls: [Player: TichuCallInput] = [
            Player(team: .teamB, position: 0): TichuCallInput(type: .small, isSuccess: false)
        ]
        let snapshot = GameSnapshot(
            game: game,
            currentTeamACardScore: -25,
            currentOneTwoFinish: true,
            currentOneTwoFinishTeam: .teamA,
            currentTichuCalls: calls
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(GameSnapshot.self, from: data)

        #expect(decoded.game.teamA.totalScore == 120)
        #expect(decoded.game.teamB.totalScore == 80)
        #expect(decoded.game.targetScore == 500)
        #expect(decoded.game.rounds.count == 2)
        #expect(decoded.game.rounds[0].teamACardScore == -25)
        #expect(decoded.game.rounds[0].tichuCalls.count == 1)
        #expect(decoded.game.rounds[0].tichuCalls[0].isLarge == true)
        #expect(decoded.game.rounds[1].isOneTwoFinish == true)
        #expect(decoded.game.rounds[1].oneTwoFinishTeam == .teamB)
        #expect(decoded.currentTeamACardScore == -25)
        #expect(decoded.currentOneTwoFinishTeam == .teamA)
        #expect(decoded.currentTichuCalls[Player(team: .teamB, position: 0)]?.type == .small)
    }

    /// GameStorage 파일 저장/로드 왕복
    @Test func storageSaveAndLoad() {
        let storage = GameStorage()
        var game = Game(targetScore: 1000)
        game.rounds = [Round(roundNumber: 1, teamACardScore: 60)]
        game.teamA.totalScore = 60
        game.teamB.totalScore = 40
        let snap = GameSnapshot(
            game: game,
            currentTeamACardScore: 50,
            currentOneTwoFinish: false,
            currentOneTwoFinishTeam: nil,
            currentTichuCalls: [:]
        )
        storage.save(snap)

        let loaded = storage.load()
        #expect(loaded != nil)
        #expect(loaded?.game.rounds.count == 1)
        #expect(loaded?.game.teamA.totalScore == 60)
        #expect(loaded?.game.teamB.totalScore == 40)
    }
}
