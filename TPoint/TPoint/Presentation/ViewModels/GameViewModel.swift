//
//  GameViewModel.swift
//  TPoint
//

import Foundation

protocol GameViewModelDelegate: AnyObject {
    func gameDidUpdate()
    func gameDidEnd(winner: TeamType)
}

enum ThemeMode: Int {
    case system = 0
    case light = 1
    case dark = 2
}

final class GameViewModel {

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let targetScore = "targetScore"
        static let themeMode = "themeMode"
    }

    // MARK: - Properties

    weak var delegate: GameViewModelDelegate?

    private(set) var game: Game
    private let calculateScoreUseCase: CalculateScoreUseCaseProtocol
    private let storage = GameStorage()
    private let historyStorage = HistoryStorage()

    // 현재 라운드 입력 상태
    var currentTeamACardScore: Int = 50
    var currentOneTwoFinish: Bool = false
    var currentOneTwoFinishTeam: TeamType?
    var currentTichuCalls: [Player: TichuCallInput] = [:]

    // 설정 - 목표 점수
    var targetScore: Int {
        get {
            let saved = UserDefaults.standard.integer(forKey: Keys.targetScore)
            return saved > 0 ? saved : 1000
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.targetScore)
            game.targetScore = newValue
            persist()
            delegate?.gameDidUpdate()
        }
    }

    // 설정 - 테마 모드
    var themeMode: ThemeMode {
        get {
            ThemeMode(rawValue: UserDefaults.standard.integer(forKey: Keys.themeMode)) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.themeMode)
        }
    }

    // MARK: - Computed Properties

    var teamAScore: Int { game.teamA.totalScore }
    var teamBScore: Int { game.teamB.totalScore }
    var rounds: [Round] { game.rounds }
    var roundCount: Int { game.rounds.count }
    var isGameOver: Bool { game.isGameOver }
    var winner: TeamType? { game.winner }

    var currentRound: Int { game.rounds.count + 1 }

    var currentTeamBCardScore: Int {
        100 - currentTeamACardScore
    }

    // MARK: - Initialization

    init(calculateScoreUseCase: CalculateScoreUseCaseProtocol = CalculateScoreUseCase()) {
        self.game = Game()
        self.calculateScoreUseCase = calculateScoreUseCase
        // Load saved target score
        let savedTargetScore = UserDefaults.standard.integer(forKey: Keys.targetScore)
        if savedTargetScore > 0 {
            self.game.targetScore = savedTargetScore
        }
        resetCurrentRoundInput()
        // 저장된 진행 중 게임이 있으면 복원
        restoreIfAvailable()
    }

    // MARK: - Persistence

    private func restoreIfAvailable() {
        guard let snapshot = storage.load() else { return }
        game = snapshot.game
        currentTeamACardScore = snapshot.currentTeamACardScore
        currentOneTwoFinish = snapshot.currentOneTwoFinish
        currentOneTwoFinishTeam = snapshot.currentOneTwoFinishTeam
        currentTichuCalls = snapshot.currentTichuCalls
    }

    private func persist() {
        storage.save(GameSnapshot(
            game: game,
            currentTeamACardScore: currentTeamACardScore,
            currentOneTwoFinish: currentOneTwoFinish,
            currentOneTwoFinishTeam: currentOneTwoFinishTeam,
            currentTichuCalls: currentTichuCalls
        ))
    }

    // MARK: - Public Methods

    func setTeamACardScore(_ score: Int) {
        // 카드 점수는 -25~125 범위 (슬라이더 및 Android와 동일). 상대팀은 100 - 값.
        currentTeamACardScore = max(-25, min(125, score))
        persist()
        delegate?.gameDidUpdate()
    }

    func setOneTwoFinish(enabled: Bool, team: TeamType?) {
        currentOneTwoFinish = enabled
        currentOneTwoFinishTeam = team
        persist()
        delegate?.gameDidUpdate()
    }

    func setTichuCall(for player: Player, type: TichuType?, isSuccess: Bool) {
        if let type = type {
            currentTichuCalls[player] = TichuCallInput(type: type, isSuccess: isSuccess)
        } else {
            currentTichuCalls.removeValue(forKey: player)
        }
        persist()
        delegate?.gameDidUpdate()
    }

    func getTichuCall(for player: Player) -> TichuCallInput? {
        currentTichuCalls[player]
    }

    func addRound() {
        // 원투피니시 시 상대팀은 1등이 불가능하므로 티추 성공을 강제로 실패 처리
        let oneTwoOpponent = currentOneTwoFinish ? currentOneTwoFinishTeam?.opponent : nil
        let tichuCalls = currentTichuCalls.compactMap { (player, input) -> TichuCall? in
            let isSuccess = (player.team == oneTwoOpponent) ? false : input.isSuccess
            return TichuCall(
                player: player,
                isLarge: input.type == .large,
                isSuccess: isSuccess
            )
        }

        let round = Round(
            roundNumber: game.rounds.count + 1,
            teamACardScore: currentTeamACardScore,
            isOneTwoFinish: currentOneTwoFinish,
            oneTwoFinishTeam: currentOneTwoFinishTeam,
            tichuCalls: tichuCalls
        )

        let score = calculateScoreUseCase.calculate(round: round)

        game.rounds.append(round)
        game.teamA.totalScore += score.teamAScore
        game.teamB.totalScore += score.teamBScore

        resetCurrentRoundInput()
        persist()

        if let winner = game.winner {
            delegate?.gameDidEnd(winner: winner)
        } else {
            delegate?.gameDidUpdate()
        }
    }

    func getRoundScore(at index: Int) -> RoundScore? {
        guard index < game.rounds.count else { return nil }
        return calculateScoreUseCase.calculate(round: game.rounds[index])
    }

    func newGame() {
        // 라운드가 있는 현재 게임은 새 게임 시작 시 기록에 보관
        if !game.rounds.isEmpty {
            historyStorage.append(GameHistoryEntry(completedAt: Date(), game: game))
        }
        game.reset()
        resetCurrentRoundInput()
        persist()
        delegate?.gameDidUpdate()
    }

    func loadHistory() -> [GameHistoryEntry] {
        historyStorage.load()
    }

    func clearHistory() {
        historyStorage.clear()
    }

    func deleteRound(at index: Int) {
        guard index >= 0 && index < game.rounds.count else { return }

        let round = game.rounds[index]
        let score = calculateScoreUseCase.calculate(round: round)

        // 점수 차감
        game.teamA.totalScore -= score.teamAScore
        game.teamB.totalScore -= score.teamBScore

        // 라운드 삭제
        game.rounds.remove(at: index)

        // 라운드 번호 재정렬
        for i in index..<game.rounds.count {
            game.rounds[i] = Round(
                roundNumber: i + 1,
                teamACardScore: game.rounds[i].teamACardScore,
                isOneTwoFinish: game.rounds[i].isOneTwoFinish,
                oneTwoFinishTeam: game.rounds[i].oneTwoFinishTeam,
                tichuCalls: game.rounds[i].tichuCalls
            )
        }

        persist()
        delegate?.gameDidUpdate()
    }

    // MARK: - Private Methods

    private func resetCurrentRoundInput() {
        currentTeamACardScore = 50
        currentOneTwoFinish = false
        currentOneTwoFinishTeam = nil
        currentTichuCalls = [:]
    }
}

// MARK: - Supporting Types

enum TichuType: String, Codable {
    case small  // 100점
    case large  // 200점
}

struct TichuCallInput: Codable {
    var type: TichuType
    var isSuccess: Bool
}
