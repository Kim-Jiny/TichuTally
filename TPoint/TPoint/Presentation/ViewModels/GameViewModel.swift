//
//  GameViewModel.swift
//  TPoint
//

import Foundation

protocol GameViewModelDelegate: AnyObject {
    func gameDidUpdate()
    func gameDidEnd(winner: TeamType)
}

final class GameViewModel {

    // MARK: - Properties

    weak var delegate: GameViewModelDelegate?

    private(set) var game: Game
    private let calculateScoreUseCase: CalculateScoreUseCaseProtocol

    // 현재 라운드 입력 상태
    var currentTeamACardScore: Int = 50
    var currentOneTwoFinish: Bool = false
    var currentOneTwoFinishTeam: TeamType?
    var currentTichuCalls: [Player: TichuCallInput] = [:]

    // MARK: - Computed Properties

    var teamAScore: Int { game.teamA.totalScore }
    var teamBScore: Int { game.teamB.totalScore }
    var rounds: [Round] { game.rounds }
    var roundCount: Int { game.rounds.count }
    var isGameOver: Bool { game.isGameOver }
    var winner: TeamType? { game.winner }

    var currentTeamBCardScore: Int {
        100 - currentTeamACardScore
    }

    // MARK: - Initialization

    init(calculateScoreUseCase: CalculateScoreUseCaseProtocol = CalculateScoreUseCase()) {
        self.game = Game()
        self.calculateScoreUseCase = calculateScoreUseCase
        resetCurrentRoundInput()
    }

    // MARK: - Public Methods

    func setTeamACardScore(_ score: Int) {
        currentTeamACardScore = max(0, min(100, score))
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
        guard index < game.rounds.count else { return nil }
        return calculateScoreUseCase.calculate(round: game.rounds[index])
    }

    func newGame() {
        game.reset()
        resetCurrentRoundInput()
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
