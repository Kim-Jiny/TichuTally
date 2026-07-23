//
//  ScoreHistoryView.swift
//  TPoint
//

import UIKit

protocol ScoreHistoryViewDelegate: AnyObject {
    func scoreHistoryView(_ view: ScoreHistoryView, didDeleteRoundAt index: Int)
    func scoreHistoryView(_ view: ScoreHistoryView, didRequestEditRoundAt index: Int)
}

final class ScoreHistoryView: UIView {

    // MARK: - Delegate

    weak var delegate: ScoreHistoryViewDelegate?

    // MARK: - UI Components

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = AppColors.textHint
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headerTeamALabel: UILabel = {
        let label = UILabel()
        label.text = "A"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headerTeamBLabel: UILabel = {
        let label = UILabel()
        label.text = "B"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headerDetailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = AppColors.textHint
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let emptyStateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emptyIconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "list.bullet.clipboard", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = AppColors.textHint
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = AppColors.textHint
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    private var rounds: [Round] = []
    private var scores: [RoundScore] = []

    private var contentBottomConstraint: NSLayoutConstraint?
    private var emptyBottomConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        // Header
        headerView.addSubview(headerNumberLabel)
        headerView.addSubview(headerTeamALabel)
        headerView.addSubview(headerTeamBLabel)
        headerView.addSubview(headerDetailsLabel)

        // Empty state
        emptyStateContainer.addSubview(emptyIconImageView)
        emptyStateContainer.addSubview(emptyTitleLabel)
        emptyStateContainer.addSubview(emptySubtitleLabel)

        addSubview(headerView)
        addSubview(contentStackView)
        addSubview(emptyStateContainer)

        headerDetailsLabel.text = L10n.details
        emptyTitleLabel.text = L10n.noRecordsTitle
        emptySubtitleLabel.text = L10n.noRecords

        updateColors()

        // Bottom constraints (will toggle active state)
        contentBottomConstraint = contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        emptyBottomConstraint = emptyStateContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)

        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            headerView.heightAnchor.constraint(equalToConstant: 24),

            headerNumberLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 32),
            headerNumberLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerNumberLabel.widthAnchor.constraint(equalToConstant: 32),

            headerTeamALabel.leadingAnchor.constraint(equalTo: headerNumberLabel.trailingAnchor, constant: 4),
            headerTeamALabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerTeamALabel.widthAnchor.constraint(equalToConstant: 42),

            headerTeamBLabel.leadingAnchor.constraint(equalTo: headerTeamALabel.trailingAnchor, constant: 16),
            headerTeamBLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerTeamBLabel.widthAnchor.constraint(equalToConstant: 42),

            headerDetailsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerDetailsLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // Content stack view
            contentStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Empty state
            emptyStateContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            emptyStateContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateContainer.heightAnchor.constraint(equalToConstant: 120),

            emptyIconImageView.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyIconImageView.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor, constant: 16),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 48),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 48),

            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconImageView.bottomAnchor, constant: 8),
            emptyTitleLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),

            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 4),
            emptySubtitleLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor)
        ])

        // Initial state: empty
        emptyBottomConstraint?.isActive = true
        contentBottomConstraint?.isActive = false
    }

    private func updateColors() {
        headerTeamALabel.textColor = AppColors.teamAColor
        headerTeamBLabel.textColor = AppColors.teamBColor
    }

    // MARK: - Public Methods

    func updateHistory(rounds: [Round], scores: [RoundScore]) {
        self.rounds = rounds
        self.scores = scores

        // Remove all existing row views
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let isEmpty = rounds.isEmpty

        if !isEmpty {
            // Add row views for each round
            for (index, round) in rounds.enumerated() {
                let score = scores[index]
                let rowView = ScoreHistoryRowView()
                rowView.configure(round: round, score: score)
                rowView.onDeleteTapped = { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.scoreHistoryView(self, didDeleteRoundAt: index)
                }
                rowView.onRowTapped = { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.scoreHistoryView(self, didRequestEditRoundAt: index)
                }
                contentStackView.addArrangedSubview(rowView)
            }
        }

        // Toggle visibility and constraints
        emptyStateContainer.isHidden = !isEmpty
        headerView.isHidden = isEmpty
        contentStackView.isHidden = isEmpty

        // Switch bottom constraints
        emptyBottomConstraint?.isActive = isEmpty
        contentBottomConstraint?.isActive = !isEmpty

        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
}


// MARK: - ScoreHistoryRowView

final class ScoreHistoryRowView: UIView {

    // MARK: - Callback

    var onDeleteTapped: (() -> Void)?
    var onRowTapped: (() -> Void)?

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.surfaceLight
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.textHint
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let roundLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.textHint
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(deleteButton)
        containerView.addSubview(roundLabel)
        containerView.addSubview(teamAScoreLabel)
        containerView.addSubview(separatorLabel)
        containerView.addSubview(teamBScoreLabel)
        containerView.addSubview(detailsStackView)

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        // 행 탭 시 편집
        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true

        updateColors()

        NSLayoutConstraint.activate([
            // Self height
            heightAnchor.constraint(equalToConstant: 40),

            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),

            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),

            roundLabel.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 4),
            roundLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            roundLabel.widthAnchor.constraint(equalToConstant: 32),

            teamAScoreLabel.leadingAnchor.constraint(equalTo: roundLabel.trailingAnchor, constant: 4),
            teamAScoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamAScoreLabel.widthAnchor.constraint(equalToConstant: 42),

            separatorLabel.leadingAnchor.constraint(equalTo: teamAScoreLabel.trailingAnchor),
            separatorLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            separatorLabel.widthAnchor.constraint(equalToConstant: 16),

            teamBScoreLabel.leadingAnchor.constraint(equalTo: separatorLabel.trailingAnchor),
            teamBScoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamBScoreLabel.widthAnchor.constraint(equalToConstant: 42),

            detailsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            detailsStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    private func updateColors() {
        teamAScoreLabel.textColor = AppColors.teamAColor
        teamBScoreLabel.textColor = AppColors.teamBColor
        containerView.backgroundColor = AppColors.surfaceLight
    }

    @objc private func rowTapped() {
        onRowTapped?()
    }

    @objc private func deleteButtonTapped() {
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.deleteButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.deleteButton.transform = .identity
            }
        }
        onDeleteTapped?()
    }

    func configure(round: Round, score: RoundScore) {
        roundLabel.text = "\(round.roundNumber)"
        teamAScoreLabel.text = score.teamADisplay
        teamBScoreLabel.text = score.teamBDisplay

        // Clear previous tags
        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // One-Two finish tag
        if round.isOneTwoFinish, let team = round.oneTwoFinishTeam {
            let tag = createTag(text: "1-2", team: team)
            detailsStackView.addArrangedSubview(tag)
        }

        // Tichu call tags
        for call in round.tichuCalls {
            let tichuShort = call.isLarge ? "L" : "S"
            let result = call.isSuccess ? "O" : "X"
            let text = "\(tichuShort)\(result)"
            let tag = createTag(text: text, team: call.player.team, isSuccess: call.isSuccess, isLarge: call.isLarge)
            detailsStackView.addArrangedSubview(tag)
        }
    }

    private func createTag(text: String, team: TeamType, isSuccess: Bool? = nil, isLarge: Bool = false) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 4

        var bgColor: UIColor
        let textColor: UIColor = .white

        if let success = isSuccess {
            if isLarge {
                bgColor = success ? AppColors.largeTichuColor : AppColors.failureColor.withAlphaComponent(0.7)
            } else {
                bgColor = success ? AppColors.successColor : AppColors.failureColor.withAlphaComponent(0.7)
            }
        } else {
            bgColor = AppColors.teamColor(for: team)
        }

        container.backgroundColor = bgColor

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6)
        ])

        return container
    }
}
