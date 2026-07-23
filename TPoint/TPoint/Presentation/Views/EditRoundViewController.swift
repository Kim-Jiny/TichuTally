//
//  EditRoundViewController.swift
//  TPoint
//
//  기존 라운드 편집 (RoundInputView 재사용)
//

import UIKit

protocol EditRoundViewControllerDelegate: AnyObject {
    func editRoundViewController(
        _ controller: EditRoundViewController,
        didSaveAt index: Int,
        teamACardScore: Int,
        isOneTwoFinish: Bool,
        oneTwoFinishTeam: TeamType?,
        tichuCalls: [Player: TichuCallInput]
    )
}

final class EditRoundViewController: UIViewController {

    weak var delegate: EditRoundViewControllerDelegate?

    private let index: Int
    private let roundNumber: Int
    private var teamACardScore: Int
    private var oneTwoFinish: Bool
    private var oneTwoFinishTeam: TeamType?
    private var tichuCalls: [Player: TichuCallInput]

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackgroundElevated
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(AppColors.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let roundInputView: RoundInputView = {
        let view = RoundInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(index: Int, round: Round) {
        self.index = index
        self.roundNumber = round.roundNumber
        self.teamACardScore = round.teamACardScore
        self.oneTwoFinish = round.isOneTwoFinish
        self.oneTwoFinishTeam = round.oneTwoFinishTeam
        self.tichuCalls = Dictionary(uniqueKeysWithValues: round.tichuCalls.map {
            ($0.player, TichuCallInput(type: $0.isLarge ? .large : .small, isSuccess: $0.isSuccess))
        })
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        roundInputView.delegate = self
        roundInputView.configure(
            teamACardScore: teamACardScore,
            oneTwoFinish: oneTwoFinish,
            oneTwoFinishTeam: oneTwoFinishTeam,
            tichuCalls: tichuCalls
        )
        roundInputView.setAddButtonTitle(L10n.save)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        titleLabel.text = L10n.roundNumberFormat(roundNumber)
        cancelButton.setTitle(L10n.cancel, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(roundInputView)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            roundInputView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            roundInputView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            roundInputView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            roundInputView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension EditRoundViewController: RoundInputViewDelegate {

    func roundInputView(_ view: RoundInputView, didChangeTeamAScore score: Int) {
        teamACardScore = score
    }

    func roundInputView(_ view: RoundInputView, didChangeOneTwoFinish enabled: Bool, team: TeamType?) {
        oneTwoFinish = enabled
        oneTwoFinishTeam = team
    }

    func roundInputView(_ view: RoundInputView, didChangeTichuCall player: Player, type: TichuType?, isSuccess: Bool) {
        if let type = type {
            tichuCalls[player] = TichuCallInput(type: type, isSuccess: isSuccess)
        } else {
            tichuCalls.removeValue(forKey: player)
        }
    }

    func roundInputViewDidTapAddRound(_ view: RoundInputView) {
        let idx = index
        let score = teamACardScore
        let otf = oneTwoFinish
        let otfTeam = oneTwoFinishTeam
        let calls = tichuCalls
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.editRoundViewController(
                self,
                didSaveAt: idx,
                teamACardScore: score,
                isOneTwoFinish: otf,
                oneTwoFinishTeam: otfTeam,
                tichuCalls: calls
            )
        }
    }
}
