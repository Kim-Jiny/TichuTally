//
//  GameStorage.swift
//  TPoint
//
//  진행 중인 게임 상태를 파일에 JSON으로 영속화한다.
//  프로세스가 종료돼도 앱 재실행 시 게임을 이어갈 수 있게 한다.
//

import Foundation

/// 저장/복원 대상 스냅샷 (게임 + 현재 입력 상태)
struct GameSnapshot: Codable {
    var game: Game
    var currentTeamACardScore: Int
    var currentOneTwoFinish: Bool
    var currentOneTwoFinishTeam: TeamType?
    var currentTichuCalls: [Player: TichuCallInput]
}

final class GameStorage {

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("current_game.json")
    }()

    func save(_ snapshot: GameSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ GameStorage save failed: \(error)")
        }
    }

    func load() -> GameSnapshot? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(GameSnapshot.self, from: data)
    }
}
