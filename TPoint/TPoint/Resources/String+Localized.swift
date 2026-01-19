//
//  String+Localized.swift
//  TPoint
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys

enum L10n {
    // Team
    static let teamA = "team_a".localized
    static let teamB = "team_b".localized
    static let pointsSuffix = "points_suffix".localized

    // Round Input
    static let roundInputTitle = "round_input_title".localized
    static let tichuSectionTitle = "tichu_section_title".localized
    static let oneTwoFinish = "one_two_finish".localized
    static let none = "none".localized
    static let cardScore = "card_score".localized
    static let addRound = "add_round".localized

    // Score History
    static let roundHistory = "round_history".localized
    static let noRecords = "no_records".localized
    static let roundPrefix = "round_prefix".localized

    // Tichu
    static let smallTichu = "small_tichu".localized
    static let largeTichu = "large_tichu".localized
    static let oneTwo = "one_two".localized

    // Game
    static let newGame = "new_game".localized
    static let gameOver = "game_over".localized
    static let finalScore = "final_score".localized
    static let confirm = "confirm".localized
    static let cancel = "cancel".localized
    static let delete = "delete".localized
    static let newGameConfirm = "new_game_confirm".localized

    static func winnerMessage(_ team: String) -> String {
        "winner_message".localized(with: team)
    }

    static func playerFormat(_ team: String, _ number: Int) -> String {
        "player_format".localized(with: team, number)
    }
}
