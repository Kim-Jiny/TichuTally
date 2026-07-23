//
//  GameViewController.swift
//  TPoint
//

import UIKit
import GoogleMobileAds

final class GameViewController: UIViewController {

    // MARK: - UI Components

    private let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackgroundElevated
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.textSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let recordsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "list.bullet.rectangle", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.textSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let roundLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let newGameTopButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.counterclockwise", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.failureColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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

    // Banner Ad
    private let bannerAdView: BannerAdView = {
        let view = BannerAdView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.surfaceLight
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
        applyTheme()
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppColors.surfaceLight
        navigationController?.setNavigationBarHidden(true, animated: false)

        teamAScoreView.translatesAutoresizingMaskIntoConstraints = false
        teamBScoreView.translatesAutoresizingMaskIntoConstraints = false
        roundInputView.translatesAutoresizingMaskIntoConstraints = false
        scoreHistoryView.translatesAutoresizingMaskIntoConstraints = false

        // Top bar
        view.addSubview(topBarView)
        topBarView.addSubview(settingsButton)
        topBarView.addSubview(recordsButton)
        topBarView.addSubview(roundLabel)
        topBarView.addSubview(newGameTopButton)

        view.addSubview(bannerAdView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(teamAScoreView)
        contentView.addSubview(teamBScoreView)
        contentView.addSubview(roundInputView)
        contentView.addSubview(scoreHistoryView)

        roundInputView.delegate = self
        scoreHistoryView.delegate = self

        // Banner height (will be updated after ad loads)
        bannerHeightConstraint = bannerAdView.heightAnchor.constraint(equalToConstant: 50)

        NSLayoutConstraint.activate([
            // Top bar
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 52),

            settingsButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 16),
            settingsButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),

            recordsButton.leadingAnchor.constraint(equalTo: settingsButton.trailingAnchor, constant: 4),
            recordsButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            recordsButton.widthAnchor.constraint(equalToConstant: 44),
            recordsButton.heightAnchor.constraint(equalToConstant: 44),

            roundLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            roundLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),

            newGameTopButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -16),
            newGameTopButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            newGameTopButton.widthAnchor.constraint(equalToConstant: 44),
            newGameTopButton.heightAnchor.constraint(equalToConstant: 44),

            // Banner at bottom
            bannerAdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerAdView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerAdView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerHeightConstraint!,

            // ScrollView below top bar, above banner
            scrollView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
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
            teamAScoreView.heightAnchor.constraint(equalToConstant: 130),

            teamBScoreView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            teamBScoreView.leadingAnchor.constraint(equalTo: teamAScoreView.trailingAnchor, constant: 12),
            teamBScoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            teamBScoreView.heightAnchor.constraint(equalToConstant: 130),
            teamBScoreView.widthAnchor.constraint(equalTo: teamAScoreView.widthAnchor),

            roundInputView.topAnchor.constraint(equalTo: teamAScoreView.bottomAnchor, constant: 16),
            roundInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            roundInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            scoreHistoryView.topAnchor.constraint(equalTo: roundInputView.bottomAnchor, constant: 16),
            scoreHistoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scoreHistoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scoreHistoryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        recordsButton.addTarget(self, action: #selector(recordsTapped), for: .touchUpInside)
        newGameTopButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
    }

    private func setupBannerAd() {
        bannerAdView.configure(rootViewController: self)
    }

    private func updateColors() {
        view.backgroundColor = AppColors.surfaceLight
        topBarView.backgroundColor = AppColors.cardBackgroundElevated
        roundLabel.textColor = AppColors.textPrimary
        settingsButton.tintColor = AppColors.textSecondary
        recordsButton.tintColor = AppColors.textSecondary
        newGameTopButton.tintColor = AppColors.failureColor
        bannerAdView.backgroundColor = AppColors.surfaceLight
    }

    // MARK: - Actions

    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController(
            targetScore: viewModel.targetScore,
            themeMode: viewModel.themeMode,
            teamAName: viewModel.teamAName,
            teamBName: viewModel.teamBName
        )
        settingsVC.delegate = self
        present(settingsVC, animated: false)
    }

    @objc private func recordsTapped() {
        let recordsVC = RecordsViewController(history: viewModel.loadHistory())
        recordsVC.onClearHistory = { [weak self] in
            self?.viewModel.clearHistory()
        }
        navigationController?.pushViewController(recordsVC, animated: true)
    }

    @objc private func newGameTapped() {
        let newGameVC = NewGameViewController(
            teamAScore: viewModel.teamAScore,
            teamBScore: viewModel.teamBScore
        )
        newGameVC.delegate = self
        present(newGameVC, animated: false)
    }

    // MARK: - Undo Toast

    private weak var undoToast: UIView?

    private func showUndoToast() {
        undoToast?.removeFromSuperview()

        let toast = UIView()
        toast.backgroundColor = AppColors.cardBackgroundElevated
        toast.layer.cornerRadius = 12
        toast.layer.shadowColor = UIColor.black.cgColor
        toast.layer.shadowOpacity = 0.2
        toast.layer.shadowRadius = 8
        toast.layer.shadowOffset = CGSize(width: 0, height: 2)
        toast.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = L10n.roundDeleted
        label.textColor = AppColors.textPrimary
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false

        let undoButton = UIButton(type: .system)
        undoButton.setTitle(L10n.undo, for: .normal)
        undoButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        undoButton.setTitleColor(AppColors.teamAColor, for: .normal)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.addTarget(self, action: #selector(undoDeleteTapped), for: .touchUpInside)

        toast.addSubview(label)
        toast.addSubview(undoButton)
        view.addSubview(toast)
        undoToast = toast

        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toast.bottomAnchor.constraint(equalTo: bannerAdView.topAnchor, constant: -8),
            toast.heightAnchor.constraint(equalToConstant: 48),

            label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: toast.centerYAnchor),

            undoButton.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -16),
            undoButton.centerYAnchor.constraint(equalTo: toast.centerYAnchor)
        ])

        toast.alpha = 0
        UIView.animate(withDuration: 0.2) { toast.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak toast] in
            UIView.animate(withDuration: 0.2, animations: { toast?.alpha = 0 }) { _ in
                toast?.removeFromSuperview()
            }
        }
    }

    @objc private func undoDeleteTapped() {
        viewModel.undoDelete()
        undoToast?.removeFromSuperview()
        undoToast = nil
    }

    // MARK: - Private Methods

    private func updateUI() {
        // Update round label
        roundLabel.text = L10n.roundNumberFormat(viewModel.currentRound)

        teamAScoreView.setTeamName(viewModel.teamAName)
        teamBScoreView.setTeamName(viewModel.teamBName)
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

    private func showWinnerDialog(winner: TeamType) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        let winnerName = winner == .teamA ? viewModel.teamADisplayName : viewModel.teamBDisplayName
        let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Tichu Tally"
        let shareImage = ResultImageRenderer.render(
            winnerLine: L10n.winnerMessage(winnerName),
            teamAName: viewModel.teamADisplayName,
            teamAScore: viewModel.teamAScore,
            teamAColor: AppColors.teamAColor,
            teamBName: viewModel.teamBDisplayName,
            teamBScore: viewModel.teamBScore,
            teamBColor: AppColors.teamBColor,
            winnerColor: AppColors.teamColor(for: winner),
            roundsText: L10n.roundsCount(viewModel.roundCount),
            appName: appName
        )
        let winnerVC = WinnerViewController(
            winner: winner,
            teamAScore: viewModel.teamAScore,
            teamBScore: viewModel.teamBScore,
            winnerName: winnerName,
            shareImage: shareImage
        )
        winnerVC.delegate = self
        present(winnerVC, animated: false)
    }

    private func applyTheme() {
        let style: UIUserInterfaceStyle
        switch viewModel.themeMode {
        case .system:
            style = .unspecified
        case .light:
            style = .light
        case .dark:
            style = .dark
        }

        if let windowScene = view.window?.windowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        } else {
            view.window?.overrideUserInterfaceStyle = style
        }
    }
}

// MARK: - GameViewModelDelegate

extension GameViewController: GameViewModelDelegate {
    func gameDidUpdate() {
        updateUI()
    }

    func gameDidEnd(winner: TeamType) {
        updateUI()
        showWinnerDialog(winner: winner)
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel.addRound()
        roundInputView.reset()
    }
}

// MARK: - ScoreHistoryViewDelegate

extension GameViewController: ScoreHistoryViewDelegate {
    func scoreHistoryView(_ view: ScoreHistoryView, didDeleteRoundAt index: Int) {
        guard index < viewModel.rounds.count,
              let score = viewModel.getRoundScore(at: index) else { return }

        let round = viewModel.rounds[index]
        let deleteVC = DeleteRoundViewController(roundIndex: index, round: round, score: score)
        deleteVC.delegate = self
        present(deleteVC, animated: false)
    }

    func scoreHistoryView(_ view: ScoreHistoryView, didRequestEditRoundAt index: Int) {
        guard index >= 0 && index < viewModel.rounds.count else { return }
        let editVC = EditRoundViewController(index: index, round: viewModel.rounds[index])
        editVC.delegate = self
        present(editVC, animated: true)
    }
}

// MARK: - EditRoundViewControllerDelegate

extension GameViewController: EditRoundViewControllerDelegate {
    func editRoundViewController(
        _ controller: EditRoundViewController,
        didSaveAt index: Int,
        teamACardScore: Int,
        isOneTwoFinish: Bool,
        oneTwoFinishTeam: TeamType?,
        tichuCalls: [Player: TichuCallInput]
    ) {
        let wasOver = viewModel.isGameOver
        viewModel.updateRound(
            at: index,
            teamACardScore: teamACardScore,
            isOneTwoFinish: isOneTwoFinish,
            oneTwoFinishTeam: oneTwoFinishTeam,
            tichuCalls: tichuCalls
        )
        // 편집으로 게임이 새로 종료된 경우에만 승자 다이얼로그 표시
        if !wasOver, let winner = viewModel.winner {
            showWinnerDialog(winner: winner)
        }
    }
}

// MARK: - SettingsViewControllerDelegate

extension GameViewController: SettingsViewControllerDelegate {
    func settingsDidChangeTargetScore(_ score: Int) {
        let wasOver = viewModel.isGameOver
        viewModel.targetScore = score
        // 이 델리게이트는 설정 화면이 완전히 닫힌 뒤 호출되므로 바로 present 가능.
        // 목표 점수 변경으로 게임이 "새로" 종료된 경우에만 승자 다이얼로그 표시.
        if !wasOver, let winner = viewModel.winner {
            showWinnerDialog(winner: winner)
        }
    }

    func settingsDidChangeTheme(_ mode: ThemeMode) {
        viewModel.themeMode = mode
        applyTheme()
    }

    func settingsDidChangeTeamNames(_ teamAName: String, _ teamBName: String) {
        viewModel.teamAName = teamAName
        viewModel.teamBName = teamBName
        updateUI()
    }
}

// MARK: - WinnerViewControllerDelegate

extension GameViewController: WinnerViewControllerDelegate {
    func winnerViewControllerDidTapNewGame(_ controller: WinnerViewController) {
        viewModel.newGame()
    }
}

// MARK: - NewGameViewControllerDelegate

extension GameViewController: NewGameViewControllerDelegate {
    func newGameViewControllerDidConfirm(_ controller: NewGameViewController) {
        viewModel.newGame()
    }
}

// MARK: - DeleteRoundViewControllerDelegate

extension GameViewController: DeleteRoundViewControllerDelegate {
    func deleteRoundViewControllerDidConfirm(_ controller: DeleteRoundViewController, roundIndex: Int) {
        viewModel.deleteRound(at: roundIndex)
        showUndoToast()
    }
}
