//
//  TeamScoreView.swift
//  TPoint
//

import UIKit

final class TeamScoreView: UIView {

    // MARK: - UI Components

    private let teamLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    private let teamType: TeamType

    // MARK: - Initialization

    init(teamType: TeamType) {
        self.teamType = teamType
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = teamType == .teamA ? .systemBlue.withAlphaComponent(0.1) : .systemRed.withAlphaComponent(0.1)
        layer.cornerRadius = 12

        addSubview(teamLabel)
        addSubview(scoreLabel)
        addSubview(pointsLabel)

        teamLabel.text = teamType.displayName
        teamLabel.textColor = teamType == .teamA ? .systemBlue : .systemRed
        scoreLabel.textColor = teamType == .teamA ? .systemBlue : .systemRed
        pointsLabel.text = L10n.pointsSuffix

        NSLayoutConstraint.activate([
            teamLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            teamLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            pointsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            pointsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pointsLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Public Methods

    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"
    }

    func setWinner(_ isWinner: Bool) {
        if isWinner {
            backgroundColor = teamType == .teamA ? .systemBlue.withAlphaComponent(0.3) : .systemRed.withAlphaComponent(0.3)
            layer.borderWidth = 3
            layer.borderColor = teamType == .teamA ? UIColor.systemBlue.cgColor : UIColor.systemRed.cgColor
        } else {
            backgroundColor = teamType == .teamA ? .systemBlue.withAlphaComponent(0.1) : .systemRed.withAlphaComponent(0.1)
            layer.borderWidth = 0
        }
    }
}
