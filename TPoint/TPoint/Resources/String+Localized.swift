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

    // Settings
    static let settings = "settings".localized
    static let theme = "theme".localized
    static let themeSystem = "theme_system".localized
    static let themeLight = "theme_light".localized
    static let themeDark = "theme_dark".localized
    static let targetScore = "target_score".localized
    static let customScore = "custom_score".localized
    static let save = "save".localized

    // Round
    static let roundNumber = "round_number".localized
    static let noRecordsTitle = "no_records_title".localized

    // Winner
    static let win = "win".localized
    static let winner = "winner".localized
    static let vs = "vs".localized
    static let details = "details".localized
    static let currentScore = "current_score".localized

    // Records / Statistics
    static let records = "records".localized
    static let tabHistory = "tab_history".localized
    static let tabStats = "tab_stats".localized
    static let noHistory = "no_history".localized
    static let clearHistory = "clear_history".localized
    static let clearHistoryConfirm = "clear_history_confirm".localized
    static let statTotalGames = "stat_total_games".localized
    static let statWinRate = "stat_win_rate".localized
    static let statAvgRounds = "stat_avg_rounds".localized
    static let statSmallTichu = "stat_small_tichu".localized
    static let statLargeTichu = "stat_large_tichu".localized
    static let statOneTwo = "stat_one_two".localized
    static let statHighestScore = "stat_highest_score".localized
    static let draw = "draw".localized
    static let teamNames = "team_names".localized
    static let undo = "undo".localized
    static let roundDeleted = "round_deleted".localized
    static let share = "share".localized

    static func roundsCount(_ n: Int) -> String {
        "rounds_count".localized(with: n)
    }

    static func winnerMessage(_ team: String) -> String {
        "winner_message".localized(with: team)
    }

    static func playerFormat(_ team: String, _ number: Int) -> String {
        "player_format".localized(with: team, number)
    }

    static func roundNumberFormat(_ number: Int) -> String {
        "round_number".localized(with: number)
    }
}
