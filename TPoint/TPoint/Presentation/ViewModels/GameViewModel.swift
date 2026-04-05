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
    private var roundScores: [RoundScore] = []
    private let calculateScoreUseCase: CalculateScoreUseCaseProtocol

    // 현재 라운드 입력 상태
    var currentTeamACardScore: Int = 50
    var currentOneTwoFinish: Bool = false
    var currentOneTwoFinishTeam: TeamType?
    var currentTichuCalls: [Player: TichuCallInput] = [:]

    // 설정 - 목표 점수 (메모리 캐시 + UserDefaults 영속화)
    private var _targetScore: Int
    var targetScore: Int {
        get { _targetScore }
        set {
            _targetScore = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.targetScore)
            game.targetScore = newValue
            delegate?.gameDidUpdate()
        }
    }

    // 설정 - 테마 모드 (메모리 캐시 + UserDefaults 영속화)
    private var _themeMode: ThemeMode
    var themeMode: ThemeMode {
        get { _themeMode }
        set {
            _themeMode = newValue
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
        self.calculateScoreUseCase = calculateScoreUseCase

        // UserDefaults에서 한 번만 로드해 메모리에 캐시
        let savedTargetScore = UserDefaults.standard.integer(forKey: Keys.targetScore)
        self._targetScore = savedTargetScore > 0 ? savedTargetScore : 1000
        self._themeMode = ThemeMode(rawValue: UserDefaults.standard.integer(forKey: Keys.themeMode)) ?? .system

        self.game = Game(targetScore: self._targetScore)
        resetCurrentRoundInput()
    }

    // MARK: - Public Methods

    func setTeamACardScore(_ score: Int) {
        currentTeamACardScore = max(-25, min(125, score))
        delegate?.gameDidUpdate()
    }

    func setOneTwoFinish(enabled: Bool, team: TeamType?) {
        currentOneTwoFinish = enabled
        currentOneTwoFinishTeam = team
        delegate?.gameDidUpdate()
    }

    func setTichuCall(for player: Player, type: TichuType?, isSuccess: Bool) {
        if let type = type {
            currentTichuCalls[player] = TichuCallInput(type: type, isSuccess: isSuccess)

            // 한 라운드에 성공은 한 명만 가능(먼저 난 사람). 성공으로 설정되면 나머지 콜은 자동 실패.
            if isSuccess {
                let otherPlayers = currentTichuCalls.keys.filter { $0 != player }
                for otherPlayer in otherPlayers {
                    if let otherInput = currentTichuCalls[otherPlayer] {
                        currentTichuCalls[otherPlayer] = TichuCallInput(type: otherInput.type, isSuccess: false)
                    }
                }
            }
        } else {
            currentTichuCalls.removeValue(forKey: player)
        }
        delegate?.gameDidUpdate()
    }

    func getTichuCall(for player: Player) -> TichuCallInput? {
        currentTichuCalls[player]
    }

    func addRound() {
        let tichuCalls = currentTichuCalls.compactMap { (player, input) -> TichuCall? in
            return TichuCall(
                player: player,
                isLarge: input.type == .large,
                isSuccess: input.isSuccess
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
        roundScores.append(score)
        game.teamA.totalScore += score.teamAScore
        game.teamB.totalScore += score.teamBScore

        resetCurrentRoundInput()

        if let winner = game.winner {
            delegate?.gameDidEnd(winner: winner)
        } else {
            delegate?.gameDidUpdate()
        }
    }

    func getRoundScore(at index: Int) -> RoundScore? {
        guard index >= 0 && index < roundScores.count else { return nil }
        return roundScores[index]
    }

    func newGame() {
        game.reset()
        roundScores.removeAll()
        resetCurrentRoundInput()
        delegate?.gameDidUpdate()
    }

    func deleteRound(at index: Int) {
        guard index >= 0 && index < game.rounds.count, index < roundScores.count else { return }

        // 저장된 점수로 차감 (재계산 시 계산 로직 변경과 불일치 방지)
        let deletedScore = roundScores[index]
        game.teamA.totalScore -= deletedScore.teamAScore
        game.teamB.totalScore -= deletedScore.teamBScore

        // 라운드 및 저장 점수 삭제
        game.rounds.remove(at: index)
        roundScores.remove(at: index)

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

enum TichuType {
    case small  // 100점
    case large  // 200점
}

struct TichuCallInput {
    var type: TichuType
    var isSuccess: Bool
}
