//
//  RoundInputView.swift
//  TPoint
//

import UIKit

protocol RoundInputViewDelegate: AnyObject {
    func roundInputView(_ view: RoundInputView, didChangeTeamAScore score: Int)
    func roundInputView(_ view: RoundInputView, didChangeOneTwoFinish enabled: Bool, team: TeamType?)
    func roundInputView(_ view: RoundInputView, didChangeTichuCall player: Player, type: TichuType?, isSuccess: Bool)
    func roundInputViewDidTapAddRound(_ view: RoundInputView)
}

final class RoundInputView: UIView {

    // MARK: - UI Components

    private let tichuSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var tichuCallViews: [TichuCallView] = []

    private let oneTwoFinishLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let oneTwoSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: [L10n.none, L10n.teamA, L10n.teamB])
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreDisplayContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scoreGradientLayer = CAGradientLayer()

    private let teamAScoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "50"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreSeparatorLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "50"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamABadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let teamABadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "A"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -25
        slider.maximumValue = 125
        slider.value = 50
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let teamBBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let teamBBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "B"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addRoundButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    weak var delegate: RoundInputViewDelegate?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scoreGradientLayer.frame = scoreDisplayContainer.bounds
        updateScoreGradientCornerRadius()
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
        backgroundColor = AppColors.cardBackgroundElevated
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1

        // Localized texts
        tichuSectionLabel.text = L10n.tichuSectionTitle
        oneTwoFinishLabel.text = L10n.oneTwoFinish
        scoreLabel.text = L10n.cardScore
        addRoundButton.setTitle(L10n.addRound, for: .normal)

        // Create per-player tichu call views (2 players per team: A1/A2, B1/B2)
        func makeCallView(_ player: Player) -> TichuCallView {
            let callView = TichuCallView(player: player)
            callView.delegate = self
            callView.translatesAutoresizingMaskIntoConstraints = false
            tichuCallViews.append(callView)
            return callView
        }
        let teamAPlayers = Player.allPlayers.filter { $0.team == .teamA }
        let teamBPlayers = Player.allPlayers.filter { $0.team == .teamB }

        let teamAColumn = UIStackView(arrangedSubviews: teamAPlayers.map { makeCallView($0) })
        teamAColumn.axis = .vertical
        teamAColumn.distribution = .fillEqually
        teamAColumn.spacing = 6

        let teamBColumn = UIStackView(arrangedSubviews: teamBPlayers.map { makeCallView($0) })
        teamBColumn.axis = .vertical
        teamBColumn.distribution = .fillEqually
        teamBColumn.spacing = 6

        // Tichu section
        let tichuStack = UIStackView(arrangedSubviews: [teamAColumn, teamBColumn])
        tichuStack.axis = .horizontal
        tichuStack.distribution = .fillEqually
        tichuStack.spacing = 8
        tichuStack.translatesAutoresizingMaskIntoConstraints = false

        // Score display with gradient
        scoreDisplayContainer.layer.insertSublayer(scoreGradientLayer, at: 0)

        // Score display stack
        let scoreDisplayStack = UIStackView(arrangedSubviews: [teamAScoreValueLabel, scoreSeparatorLabel, teamBScoreValueLabel])
        scoreDisplayStack.axis = .horizontal
        scoreDisplayStack.distribution = .fillEqually
        scoreDisplayStack.translatesAutoresizingMaskIntoConstraints = false

        // Slider with team badges
        teamABadge.addSubview(teamABadgeLabel)
        teamBBadge.addSubview(teamBBadgeLabel)

        let sliderStack = UIStackView(arrangedSubviews: [teamABadge, scoreSlider, teamBBadge])
        sliderStack.axis = .horizontal
        sliderStack.spacing = 8
        sliderStack.alignment = .center
        sliderStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tichuSectionLabel)
        addSubview(tichuStack)
        addSubview(oneTwoFinishLabel)
        addSubview(oneTwoSegment)
        addSubview(scoreLabel)
        addSubview(scoreDisplayContainer)
        scoreDisplayContainer.addSubview(scoreDisplayStack)
        addSubview(sliderStack)
        addSubview(addRoundButton)

        updateColors()

        NSLayoutConstraint.activate([
            // Tichu section
            tichuSectionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            tichuSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            tichuStack.topAnchor.constraint(equalTo: tichuSectionLabel.bottomAnchor, constant: 8),
            tichuStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tichuStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // One-Two finish
            oneTwoFinishLabel.topAnchor.constraint(equalTo: tichuStack.bottomAnchor, constant: 16),
            oneTwoFinishLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            oneTwoSegment.topAnchor.constraint(equalTo: oneTwoFinishLabel.bottomAnchor, constant: 8),
            oneTwoSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            oneTwoSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Card score
            scoreLabel.topAnchor.constraint(equalTo: oneTwoSegment.bottomAnchor, constant: 16),
            scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            scoreDisplayContainer.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            scoreDisplayContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scoreDisplayContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scoreDisplayContainer.heightAnchor.constraint(equalToConstant: 60),

            scoreDisplayStack.centerXAnchor.constraint(equalTo: scoreDisplayContainer.centerXAnchor),
            scoreDisplayStack.centerYAnchor.constraint(equalTo: scoreDisplayContainer.centerYAnchor),
            scoreDisplayStack.widthAnchor.constraint(equalTo: scoreDisplayContainer.widthAnchor, constant: -32),

            // Slider
            sliderStack.topAnchor.constraint(equalTo: scoreDisplayContainer.bottomAnchor, constant: 8),
            sliderStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sliderStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            teamABadge.widthAnchor.constraint(equalToConstant: 28),
            teamABadge.heightAnchor.constraint(equalToConstant: 28),
            teamABadgeLabel.centerXAnchor.constraint(equalTo: teamABadge.centerXAnchor),
            teamABadgeLabel.centerYAnchor.constraint(equalTo: teamABadge.centerYAnchor),

            teamBBadge.widthAnchor.constraint(equalToConstant: 28),
            teamBBadge.heightAnchor.constraint(equalToConstant: 28),
            teamBBadgeLabel.centerXAnchor.constraint(equalTo: teamBBadge.centerXAnchor),
            teamBBadgeLabel.centerYAnchor.constraint(equalTo: teamBBadge.centerYAnchor),

            // Add round button
            addRoundButton.topAnchor.constraint(equalTo: sliderStack.bottomAnchor, constant: 16),
            addRoundButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            addRoundButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addRoundButton.heightAnchor.constraint(equalToConstant: 48),
            addRoundButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func updateColors() {
        teamAScoreValueLabel.textColor = AppColors.teamAColor
        teamBScoreValueLabel.textColor = AppColors.teamBColor
        teamABadge.backgroundColor = AppColors.teamAColor
        teamBBadge.backgroundColor = AppColors.teamBColor

        // Score gradient
        scoreGradientLayer.colors = [
            AppColors.teamAColorLight.cgColor,
            AppColors.teamBColorLight.cgColor
        ]
        scoreGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        scoreGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        // Add round button
        addRoundButton.backgroundColor = AppColors.successColor
        addRoundButton.layer.shadowColor = AppColors.successColor.cgColor
        addRoundButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addRoundButton.layer.shadowRadius = 4
        addRoundButton.layer.shadowOpacity = 0.3

        // Slider tint
        scoreSlider.minimumTrackTintColor = AppColors.teamAColor
        scoreSlider.maximumTrackTintColor = AppColors.teamBColor
    }

    private func updateScoreGradientCornerRadius() {
        let maskPath = UIBezierPath(roundedRect: scoreDisplayContainer.bounds, cornerRadius: 12)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        scoreGradientLayer.mask = maskLayer
    }

    private func setupActions() {
        scoreSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        oneTwoSegment.addTarget(self, action: #selector(oneTwoSegmentChanged), for: .valueChanged)
        addRoundButton.addTarget(self, action: #selector(addRoundTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func sliderValueChanged() {
        // Snap to 5 point increments
        let rawValue = scoreSlider.value
        let snappedValue = round(rawValue / 5) * 5
        scoreSlider.value = snappedValue

        let score = Int(snappedValue)
        teamAScoreValueLabel.text = "\(score)"
        teamBScoreValueLabel.text = "\(100 - score)"
        delegate?.roundInputView(self, didChangeTeamAScore: score)
    }

    @objc private func oneTwoSegmentChanged() {
        let selectedIndex = oneTwoSegment.selectedSegmentIndex
        let enabled = selectedIndex != 0
        let team: TeamType? = selectedIndex == 1 ? .teamA : (selectedIndex == 2 ? .teamB : nil)

        scoreSlider.isEnabled = !enabled
        scoreSlider.alpha = enabled ? 0.5 : 1.0
        scoreDisplayContainer.alpha = enabled ? 0.5 : 1.0

        delegate?.roundInputView(self, didChangeOneTwoFinish: enabled, team: team)
    }

    @objc private func addRoundTapped() {
        // Button animation
        UIView.animate(withDuration: 0.1, animations: {
            self.addRoundButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addRoundButton.transform = .identity
            }
        }

        delegate?.roundInputViewDidTapAddRound(self)
    }

    // MARK: - Public Methods

    func reset() {
        scoreSlider.value = 50
        teamAScoreValueLabel.text = "50"
        teamBScoreValueLabel.text = "50"
        oneTwoSegment.selectedSegmentIndex = 0
        scoreSlider.isEnabled = true
        scoreSlider.alpha = 1.0
        scoreDisplayContainer.alpha = 1.0

        for callView in tichuCallViews {
            callView.reset()
        }
    }

    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }

    /// 편집 시 라운드 값으로 사전 채움
    func configure(teamACardScore: Int, oneTwoFinish: Bool, oneTwoFinishTeam: TeamType?, tichuCalls: [Player: TichuCallInput]) {
        scoreSlider.value = Float(teamACardScore)
        teamAScoreValueLabel.text = "\(teamACardScore)"
        teamBScoreValueLabel.text = "\(100 - teamACardScore)"
        let isOneTwo = oneTwoFinish && oneTwoFinishTeam != nil
        oneTwoSegment.selectedSegmentIndex = isOneTwo ? (oneTwoFinishTeam == .teamA ? 1 : 2) : 0
        // 원투피니시면 카드 점수 슬라이더 비활성/디밍 (oneTwoSegmentChanged와 동일)
        scoreSlider.isEnabled = !isOneTwo
        scoreSlider.alpha = isOneTwo ? 0.5 : 1.0
        scoreDisplayContainer.alpha = isOneTwo ? 0.5 : 1.0
        for callView in tichuCallViews {
            let input = tichuCalls[callView.player]
            callView.configure(type: input?.type, isSuccess: input?.isSuccess ?? false)
        }
    }

    func setAddButtonTitle(_ title: String) {
        addRoundButton.setTitle(title, for: .normal)
    }
}

// MARK: - TichuCallViewDelegate

extension RoundInputView: TichuCallViewDelegate {
    func tichuCallView(_ view: TichuCallView, didUpdateCall type: TichuType?, isSuccess: Bool) {
        // Pass the tichu call to delegate
        delegate?.roundInputView(self, didChangeTichuCall: view.player, type: type, isSuccess: isSuccess)

        // When success is set, automatically set other tichu calls to fail
        if isSuccess && type != nil {
            for otherView in tichuCallViews where otherView !== view {
                if otherView.hasTichuCall {
                    otherView.setSuccess(false, silent: true)
                    if let otherType = otherView.currentTichuType {
                        delegate?.roundInputView(self, didChangeTichuCall: otherView.player, type: otherType, isSuccess: false)
                    }
                }
            }
        }
    }
}
