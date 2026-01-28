//
//  DeleteRoundViewController.swift
//  TPoint
//

import UIKit

protocol DeleteRoundViewControllerDelegate: AnyObject {
    func deleteRoundViewControllerDidConfirm(_ controller: DeleteRoundViewController, roundIndex: Int)
}

final class DeleteRoundViewController: UIViewController {

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackgroundElevated
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let image = UIImage(systemName: "trash.circle.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = AppColors.failureColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let roundInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.surfaceLight
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let roundNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(AppColors.textPrimary, for: .normal)
        button.backgroundColor = AppColors.surfaceLight
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.failureColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    weak var delegate: DeleteRoundViewControllerDelegate?
    private let roundIndex: Int
    private let round: Round
    private let score: RoundScore

    // MARK: - Initialization

    init(roundIndex: Int, round: Round, score: RoundScore) {
        self.roundIndex = roundIndex
        self.round = round
        self.score = score
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        configureContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let scoreStack = UIStackView(arrangedSubviews: [teamAScoreLabel, vsLabel, teamBScoreLabel])
        scoreStack.axis = .horizontal
        scoreStack.distribution = .equalCentering
        scoreStack.alignment = .center
        scoreStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView(arrangedSubviews: [cancelButton, deleteButton])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 12
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(roundInfoContainer)
        roundInfoContainer.addSubview(roundNumberLabel)
        roundInfoContainer.addSubview(scoreStack)
        roundInfoContainer.addSubview(detailsStackView)
        containerView.addSubview(buttonsStack)

        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        containerView.alpha = 0

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            roundInfoContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            roundInfoContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            roundInfoContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            roundNumberLabel.topAnchor.constraint(equalTo: roundInfoContainer.topAnchor, constant: 12),
            roundNumberLabel.centerXAnchor.constraint(equalTo: roundInfoContainer.centerXAnchor),

            scoreStack.topAnchor.constraint(equalTo: roundNumberLabel.bottomAnchor, constant: 4),
            scoreStack.leadingAnchor.constraint(equalTo: roundInfoContainer.leadingAnchor, constant: 20),
            scoreStack.trailingAnchor.constraint(equalTo: roundInfoContainer.trailingAnchor, constant: -20),

            detailsStackView.topAnchor.constraint(equalTo: scoreStack.bottomAnchor, constant: 8),
            detailsStackView.centerXAnchor.constraint(equalTo: roundInfoContainer.centerXAnchor),
            detailsStackView.bottomAnchor.constraint(equalTo: roundInfoContainer.bottomAnchor, constant: -12),

            buttonsStack.topAnchor.constraint(equalTo: roundInfoContainer.bottomAnchor, constant: 20),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 44),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }

    private func configureContent() {
        titleLabel.text = "\(L10n.roundPrefix) \(round.roundNumber) \(L10n.delete)?"
        cancelButton.setTitle(L10n.cancel, for: .normal)
        deleteButton.setTitle(L10n.delete, for: .normal)

        roundNumberLabel.text = L10n.roundNumberFormat(round.roundNumber)
        teamAScoreLabel.text = score.teamADisplay
        teamAScoreLabel.textColor = AppColors.teamAColor
        teamBScoreLabel.text = score.teamBDisplay
        teamBScoreLabel.textColor = AppColors.teamBColor

        // Add detail tags
        if round.isOneTwoFinish, let team = round.oneTwoFinishTeam {
            let tag = createTag(text: "1-2", team: team)
            detailsStackView.addArrangedSubview(tag)
        }

        for call in round.tichuCalls {
            let tichuShort = call.isLarge ? "L" : "S"
            let result = call.isSuccess ? "O" : "X"
            let text = "\(tichuShort)\(result)"
            let tag = createTag(text: text, team: call.player.team, isSuccess: call.isSuccess, isLarge: call.isLarge)
            detailsStackView.addArrangedSubview(tag)
        }

        // If no details, hide the stack
        if detailsStackView.arrangedSubviews.isEmpty {
            detailsStackView.isHidden = true
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
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -3),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])

        return container
    }

    // MARK: - Animations

    private func animateIn() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.containerView.alpha = 0
            self.view.backgroundColor = .clear
        }, completion: { _ in
            completion()
        })
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        animateOut {
            self.dismiss(animated: false)
        }
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            cancelTapped()
        }
    }

    @objc private func deleteTapped() {
        // Button animation
        UIView.animate(withDuration: 0.1, animations: {
            self.deleteButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.deleteButton.transform = .identity
            }
        }

        animateOut {
            self.dismiss(animated: false) {
                self.delegate?.deleteRoundViewControllerDidConfirm(self, roundIndex: self.roundIndex)
            }
        }
    }
}
