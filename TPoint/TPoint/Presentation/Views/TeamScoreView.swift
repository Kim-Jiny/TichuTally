//
//  TeamScoreView.swift
//  TPoint
//

import UIKit

final class TeamScoreView: UIView {

    // MARK: - UI Components

    private let gradientLayer = CAGradientLayer()

    private let teamLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 52, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let winBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xFFD700)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let winLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.win
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    private let teamType: TeamType
    private var customName: String?
    private var isWinner: Bool = false

    // MARK: - Initialization

    init(teamType: TeamType) {
        self.teamType = teamType
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateGradientCornerRadius()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
            layer.shadowColor = UIColor.black.cgColor
        }
    }

    // MARK: - Setup

    private func setupUI() {
        layer.cornerRadius = 16
        layer.masksToBounds = false
        clipsToBounds = true

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1

        // Gradient background
        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(teamLabel)
        addSubview(scoreLabel)
        addSubview(pointsLabel)
        addSubview(winBadge)
        winBadge.addSubview(winLabel)

        updateColors()

        NSLayoutConstraint.activate([
            teamLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            teamLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            pointsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 2),
            pointsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pointsLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12),

            winBadge.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            winBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            winBadge.widthAnchor.constraint(equalToConstant: 40),
            winBadge.heightAnchor.constraint(equalToConstant: 24),

            winLabel.centerXAnchor.constraint(equalTo: winBadge.centerXAnchor),
            winLabel.centerYAnchor.constraint(equalTo: winBadge.centerYAnchor)
        ])
    }

    private func updateColors() {
        let teamColor = AppColors.teamColor(for: teamType)
        let lightColor = AppColors.teamColorLight(for: teamType)
        let mediumColor = AppColors.teamColorMedium(for: teamType)

        teamLabel.text = customName ?? teamType.displayName
        teamLabel.textColor = teamColor
        scoreLabel.textColor = teamColor
        pointsLabel.text = L10n.pointsSuffix
        pointsLabel.textColor = AppColors.textSecondary

        // Gradient from light to medium
        gradientLayer.colors = [lightColor.cgColor, mediumColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }

    private func updateGradientCornerRadius() {
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        gradientLayer.mask = maskLayer
    }

    // MARK: - Public Methods

    /// 사용자 지정 팀 이름 설정 (nil/빈 문자열이면 기본 이름 사용)
    func setTeamName(_ name: String?) {
        customName = (name?.isEmpty == false) ? name : nil
        teamLabel.text = customName ?? teamType.displayName
    }

    func updateScore(_ score: Int) {
        let previousScore = Int(scoreLabel.text ?? "0") ?? 0

        UIView.transition(with: scoreLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.scoreLabel.text = "\(score)"
        }

        // Scale animation for score change
        if score != previousScore {
            UIView.animate(withDuration: 0.15, animations: {
                self.scoreLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.scoreLabel.transform = .identity
                }
            }
        }
    }

    func setWinner(_ winner: Bool) {
        isWinner = winner
        winBadge.isHidden = !winner

        if winner {
            // Winner animation
            layer.borderWidth = 3
            layer.borderColor = AppColors.teamColor(for: teamType).cgColor

            UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat], animations: {
                self.winBadge.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })

            // Scale animation
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }
        } else {
            layer.borderWidth = 0
            winBadge.layer.removeAllAnimations()
            winBadge.transform = .identity

            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
            }
        }
    }
}
