//
//  GameViewController.swift
//  TPoint
//

import UIKit
import GoogleMobileAds

final class GameViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let teamAScoreView = TeamScoreView(teamType: .teamA)
    private let teamBScoreView = TeamScoreView(teamType: .teamB)
    private let roundInputView = RoundInputView()
    private let scoreHistoryView = ScoreHistoryView()

    private let newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Banner Ad
    private let bannerAdView: BannerAdView = {
        let view = BannerAdView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6 // 배경색 추가
        return view
    }()

    private var bannerHeightConstraint: NSLayoutConstraint?
    private var hasLoadedBanner = false

    // MARK: - Properties

    private let viewModel: GameViewModel

    // MARK: - Initialization

    init(viewModel: GameViewModel = GameViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBannerAd()
        viewModel.delegate = self
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Load banner only once after layout is ready
        if !hasLoadedBanner && view.frame.width > 0 {
            hasLoadedBanner = true
            bannerAdView.loadBannerAd()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Tichu Tally"

        teamAScoreView.translatesAutoresizingMaskIntoConstraints = false
        teamBScoreView.translatesAutoresizingMaskIntoConstraints = false
        roundInputView.translatesAutoresizingMaskIntoConstraints = false
        scoreHistoryView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bannerAdView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(teamAScoreView)
        contentView.addSubview(teamBScoreView)
        contentView.addSubview(roundInputView)
        contentView.addSubview(scoreHistoryView)
        contentView.addSubview(newGameButton)

        roundInputView.delegate = self
        scoreHistoryView.delegate = self

        // Banner height (will be updated after ad loads)
        bannerHeightConstraint = bannerAdView.heightAnchor.constraint(equalToConstant: 50)

        NSLayoutConstraint.activate([
            // Banner at bottom
            bannerAdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerAdView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerAdView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerHeightConstraint!,

            // ScrollView above banner
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bannerAdView.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            teamAScoreView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            teamAScoreView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            teamAScoreView.heightAnchor.constraint(equalToConstant: 120),

            teamBScoreView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            teamBScoreView.leadingAnchor.constraint(equalTo: teamAScoreView.trailingAnchor, constant: 16),
            teamBScoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            teamBScoreView.heightAnchor.constraint(equalToConstant: 120),
            teamBScoreView.widthAnchor.constraint(equalTo: teamAScoreView.widthAnchor),

            roundInputView.topAnchor.constraint(equalTo: teamAScoreView.bottomAnchor, constant: 16),
            roundInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            roundInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            scoreHistoryView.topAnchor.constraint(equalTo: roundInputView.bottomAnchor, constant: 16),
            scoreHistoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scoreHistoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scoreHistoryView.heightAnchor.constraint(equalToConstant: 200),

            newGameButton.topAnchor.constraint(equalTo: scoreHistoryView.bottomAnchor, constant: 20),
            newGameButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            newGameButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        newGameButton.setTitle(L10n.newGame, for: .normal)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
    }

    private func setupBannerAd() {
        bannerAdView.configure(rootViewController: self)
    }

    // MARK: - Actions

    @objc private func newGameTapped() {
        let alert = UIAlertController(
            title: L10n.newGame,
            message: L10n.newGameConfirm,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.newGame, style: .destructive) { [weak self] _ in
            self?.viewModel.newGame()
        })
        present(alert, animated: true)
    }

    // MARK: - Private Methods

    private func updateUI() {
        teamAScoreView.updateScore(viewModel.teamAScore)
        teamBScoreView.updateScore(viewModel.teamBScore)

        let scores = viewModel.rounds.enumerated().compactMap { index, _ in
            viewModel.getRoundScore(at: index)
        }
        scoreHistoryView.updateHistory(rounds: viewModel.rounds, scores: scores)

        roundInputView.setEnabled(!viewModel.isGameOver)

        if let winner = viewModel.winner {
            teamAScoreView.setWinner(winner == .teamA)
            teamBScoreView.setWinner(winner == .teamB)
        } else {
            teamAScoreView.setWinner(false)
            teamBScoreView.setWinner(false)
        }
    }

    private func showWinnerAlert(winner: TeamType) {
        let alert = UIAlertController(
            title: L10n.gameOver,
            message: "\(L10n.winnerMessage(winner.displayName))\n\n\(L10n.finalScore)\n\(L10n.teamA): \(viewModel.teamAScore)\(L10n.pointsSuffix)\n\(L10n.teamB): \(viewModel.teamBScore)\(L10n.pointsSuffix)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
        alert.addAction(UIAlertAction(title: L10n.newGame, style: .default) { [weak self] _ in
            self?.viewModel.newGame()
        })
        present(alert, animated: true)
    }
}

// MARK: - GameViewModelDelegate

extension GameViewController: GameViewModelDelegate {
    func gameDidUpdate() {
        updateUI()
    }

    func gameDidEnd(winner: TeamType) {
        updateUI()
        showWinnerAlert(winner: winner)
    }
}

// MARK: - RoundInputViewDelegate

extension GameViewController: RoundInputViewDelegate {
    func roundInputView(_ view: RoundInputView, didChangeTeamAScore score: Int) {
        viewModel.setTeamACardScore(score)
    }

    func roundInputView(_ view: RoundInputView, didChangeOneTwoFinish enabled: Bool, team: TeamType?) {
        viewModel.setOneTwoFinish(enabled: enabled, team: team)
    }

    func roundInputView(_ view: RoundInputView, didChangeTichuCall player: Player, type: TichuType?, isSuccess: Bool) {
        viewModel.setTichuCall(for: player, type: type, isSuccess: isSuccess)
    }

    func roundInputViewDidTapAddRound(_ view: RoundInputView) {
        viewModel.addRound()
        roundInputView.reset()
    }
}

// MARK: - ScoreHistoryViewDelegate

extension GameViewController: ScoreHistoryViewDelegate {
    func scoreHistoryView(_ view: ScoreHistoryView, didDeleteRoundAt index: Int) {
        viewModel.deleteRound(at: index)
    }
}
