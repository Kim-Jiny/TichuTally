//
//  AppColors.swift
//  TPoint
//

import UIKit

struct AppColors {

    // MARK: - Team A Colors (Blue)

    static var teamAColor: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x64B5F6)
                : UIColor(hex: 0x2196F3)
        }
    }

    static var teamAColorLight: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x0D1F33)
                : UIColor(hex: 0xE3F2FD)
        }
    }

    static var teamAColorMedium: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x1A3A5C)
                : UIColor(hex: 0xBBDEFB)
        }
    }

    // MARK: - Team B Colors (Red)

    static var teamBColor: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0xEF5350)
                : UIColor(hex: 0xE53935)
        }
    }

    static var teamBColorLight: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x330D0D)
                : UIColor(hex: 0xFFEBEE)
        }
    }

    static var teamBColorMedium: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x5C1A1A)
                : UIColor(hex: 0xFFCDD2)
        }
    }

    // MARK: - Status Colors

    static var successColor: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x66BB6A)
                : UIColor(hex: 0x43A047)
        }
    }

    static var failureColor: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0xEF5350)
                : UIColor(hex: 0xE53935)
        }
    }

    static var largeTichuColor: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0xFFB74D)
                : UIColor(hex: 0xFF9800)
        }
    }

    // MARK: - Background Colors

    static var cardBackground: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x1E1E1E)
                : UIColor(hex: 0xFFFFFF)
        }
    }

    static var cardBackgroundElevated: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x242424)
                : UIColor(hex: 0xFFFFFF)
        }
    }

    static var surfaceLight: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x0D0D0D)
                : UIColor(hex: 0xF5F5F5)
        }
    }

    // MARK: - Text Colors

    static var textPrimary: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0xE8E8E8)
                : UIColor(hex: 0x212121)
        }
    }

    static var textSecondary: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x9E9E9E)
                : UIColor(hex: 0x757575)
        }
    }

    static var textHint: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x5A5A5A)
                : UIColor(hex: 0xBDBDBD)
        }
    }

    // MARK: - Helper Methods

    static func teamColor(for team: TeamType) -> UIColor {
        team == .teamA ? teamAColor : teamBColor
    }

    static func teamColorLight(for team: TeamType) -> UIColor {
        team == .teamA ? teamAColorLight : teamBColorLight
    }

    static func teamColorMedium(for team: TeamType) -> UIColor {
        team == .teamA ? teamAColorMedium : teamBColorMedium
    }
}

// MARK: - UIColor Extension

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
