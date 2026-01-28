//
//  TichuCallView.swift
//  TPoint
//

import UIKit

protocol TichuCallViewDelegate: AnyObject {
    func tichuCallView(_ view: TichuCallView, didUpdateCall type: TichuType?, isSuccess: Bool)
}

final class TichuCallView: UIView {

    // MARK: - UI Components

    private let teamBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let teamLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let smallTichuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("S", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let largeTichuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("L", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let successButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    let team: TeamType
    weak var delegate: TichuCallViewDelegate?

    private var selectedType: TichuType? {
        didSet {
            updateButtonStates()
            notifyDelegate()
        }
    }

    private var isSuccess: Bool = false {
        didSet {
            updateButtonStates()
            if !isSilentUpdate {
                notifyDelegate()
            }
        }
    }

    private var isSilentUpdate: Bool = false

    // Compatibility properties for RoundInputView
    var player: Player {
        Player(team: team, position: 0)
    }

    var hasTichuCall: Bool {
        selectedType != nil
    }

    var currentTichuType: TichuType? {
        selectedType
    }

    // MARK: - Initialization

    init(team: TeamType) {
        self.team = team
        super.init(frame: .zero)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateButtonStates()
            updateTeamBadgeColor()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = AppColors.cardBackgroundElevated
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.08

        addSubview(teamBadge)
        teamBadge.addSubview(teamLabel)
        addSubview(smallTichuButton)
        addSubview(largeTichuButton)
        addSubview(successButton)

        teamLabel.text = team.shortName
        updateTeamBadgeColor()

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),

            teamBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            teamBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            teamBadge.widthAnchor.constraint(equalToConstant: 28),
            teamBadge.heightAnchor.constraint(equalToConstant: 28),

            teamLabel.centerXAnchor.constraint(equalTo: teamBadge.centerXAnchor),
            teamLabel.centerYAnchor.constraint(equalTo: teamBadge.centerYAnchor),

            smallTichuButton.leadingAnchor.constraint(equalTo: teamBadge.trailingAnchor, constant: 8),
            smallTichuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            smallTichuButton.widthAnchor.constraint(equalToConstant: 36),
            smallTichuButton.heightAnchor.constraint(equalToConstant: 32),

            largeTichuButton.leadingAnchor.constraint(equalTo: smallTichuButton.trailingAnchor, constant: 6),
            largeTichuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            largeTichuButton.widthAnchor.constraint(equalToConstant: 36),
            largeTichuButton.heightAnchor.constraint(equalToConstant: 32),

            successButton.leadingAnchor.constraint(equalTo: largeTichuButton.trailingAnchor, constant: 6),
            successButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            successButton.widthAnchor.constraint(equalToConstant: 36),
            successButton.heightAnchor.constraint(equalToConstant: 32),
            successButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ])

        updateButtonStates()
    }

    private func updateTeamBadgeColor() {
        teamBadge.backgroundColor = AppColors.teamColor(for: team)
    }

    private func setupActions() {
        smallTichuButton.addTarget(self, action: #selector(smallTichuTapped), for: .touchUpInside)
        largeTichuButton.addTarget(self, action: #selector(largeTichuTapped), for: .touchUpInside)
        successButton.addTarget(self, action: #selector(successTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func smallTichuTapped() {
        animateButton(smallTichuButton)
        if selectedType == .small {
            selectedType = nil
        } else {
            selectedType = .small
        }
    }

    @objc private func largeTichuTapped() {
        animateButton(largeTichuButton)
        if selectedType == .large {
            selectedType = nil
        } else {
            selectedType = .large
        }
    }

    @objc private func successTapped() {
        guard selectedType != nil else { return }
        animateButton(successButton)
        isSuccess.toggle()
    }

    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }

    // MARK: - Private Methods

    private func updateButtonStates() {
        let isSmallSelected = selectedType == .small
        let isLargeSelected = selectedType == .large
        let hasTichuCall = selectedType != nil

        let teamColor = AppColors.teamColor(for: team)

        // Small Tichu button
        smallTichuButton.backgroundColor = isSmallSelected ? teamColor : .clear
        smallTichuButton.setTitleColor(isSmallSelected ? .white : teamColor, for: .normal)
        smallTichuButton.layer.borderColor = (isSmallSelected ? teamColor : AppColors.textHint).cgColor

        // Large Tichu button
        let orangeColor = AppColors.largeTichuColor
        largeTichuButton.backgroundColor = isLargeSelected ? orangeColor : .clear
        largeTichuButton.setTitleColor(isLargeSelected ? .white : orangeColor, for: .normal)
        largeTichuButton.layer.borderColor = (isLargeSelected ? orangeColor : AppColors.textHint).cgColor

        // Success/Fail button
        if hasTichuCall {
            if isSuccess {
                successButton.backgroundColor = AppColors.successColor
                successButton.setTitleColor(.white, for: .normal)
                successButton.setTitle("O", for: .normal)
                successButton.layer.borderColor = AppColors.successColor.cgColor
            } else {
                successButton.backgroundColor = AppColors.failureColor
                successButton.setTitleColor(.white, for: .normal)
                successButton.setTitle("X", for: .normal)
                successButton.layer.borderColor = AppColors.failureColor.cgColor
            }
            successButton.isEnabled = true
        } else {
            successButton.backgroundColor = .clear
            successButton.setTitleColor(AppColors.textHint, for: .normal)
            successButton.setTitle("-", for: .normal)
            successButton.layer.borderColor = AppColors.textHint.cgColor
            successButton.isEnabled = false
        }
    }

    private func notifyDelegate() {
        delegate?.tichuCallView(self, didUpdateCall: selectedType, isSuccess: isSuccess)
    }

    // MARK: - Public Methods

    func reset() {
        selectedType = nil
        isSuccess = false
    }

    func setSuccess(_ success: Bool, silent: Bool = false) {
        guard selectedType != nil else { return }
        isSilentUpdate = silent
        isSuccess = success
        isSilentUpdate = false
    }
}
