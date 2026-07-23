//
//  WinnerViewController.swift
//  TPoint
//

import UIKit

protocol WinnerViewControllerDelegate: AnyObject {
    func winnerViewControllerDidTapNewGame(_ controller: WinnerViewController)
}

final class WinnerViewController: UIViewController {

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackgroundElevated
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let trophyImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        let image = UIImage(systemName: "trophy.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor(hex: 0xFFD700) // Gold
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let winnerLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.winner
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scoreGradientLayer = CAGradientLayer()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.vs
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.confirm, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(AppColors.textPrimary, for: .normal)
        button.backgroundColor = AppColors.surfaceLight
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.newGame, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.successColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.share, for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    weak var delegate: WinnerViewControllerDelegate?
    private let winner: TeamType
    private let teamAScore: Int
    private let teamBScore: Int
    private let winnerName: String?
    private let shareText: String?

    // MARK: - Initialization

    init(winner: TeamType, teamAScore: Int, teamBScore: Int, winnerName: String? = nil, shareText: String? = nil) {
        self.winner = winner
        self.teamAScore = teamAScore
        self.teamBScore = teamBScore
        self.winnerName = winnerName
        self.shareText = shareText
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scoreGradientLayer.frame = scoreContainer.bounds
        updateGradientCornerRadius()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        // Score container gradient
        scoreContainer.layer.insertSublayer(scoreGradientLayer, at: 0)

        let scoreStack = UIStackView(arrangedSubviews: [teamAScoreLabel, vsLabel, teamBScoreLabel])
        scoreStack.axis = .horizontal
        scoreStack.distribution = .equalCentering
        scoreStack.alignment = .center
        scoreStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView(arrangedSubviews: [confirmButton, newGameButton])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 12
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        containerView.addSubview(trophyImageView)
        containerView.addSubview(winnerLabel)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(scoreContainer)
        scoreContainer.addSubview(scoreStack)
        containerView.addSubview(shareButton)
        containerView.addSubview(buttonsStack)

        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        trophyImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),

            trophyImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            trophyImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            trophyImageView.widthAnchor.constraint(equalToConstant: 80),
            trophyImageView.heightAnchor.constraint(equalToConstant: 80),

            winnerLabel.topAnchor.constraint(equalTo: trophyImageView.bottomAnchor, constant: 12),
            winnerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            teamNameLabel.topAnchor.constraint(equalTo: winnerLabel.bottomAnchor, constant: 4),
            teamNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            scoreContainer.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 20),
            scoreContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scoreContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            scoreContainer.heightAnchor.constraint(equalToConstant: 70),

            scoreStack.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreStack.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            scoreStack.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor, constant: 20),
            scoreStack.trailingAnchor.constraint(equalTo: scoreContainer.trailingAnchor, constant: -20),

            shareButton.topAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: 16),
            shareButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            shareButton.heightAnchor.constraint(equalToConstant: 44),

            buttonsStack.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 12),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 48),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }

    @objc private func shareTapped() {
        guard let text = shareText else { return }
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        activityVC.popoverPresentationController?.sourceRect = shareButton.bounds
        present(activityVC, animated: true)
    }

    private func configureContent() {
        let winnerColor = AppColors.teamColor(for: winner)
        teamNameLabel.text = winnerName ?? winner.displayName
        teamNameLabel.textColor = winnerColor

        shareButton.tintColor = winnerColor
        shareButton.setTitleColor(winnerColor, for: .normal)
        shareButton.layer.borderColor = winnerColor.cgColor
        shareButton.isHidden = (shareText == nil)

        teamAScoreLabel.text = "\(teamAScore)"
        teamAScoreLabel.textColor = AppColors.teamAColor
        teamBScoreLabel.text = "\(teamBScore)"
        teamBScoreLabel.textColor = AppColors.teamBColor

        // Gradient background
        scoreGradientLayer.colors = [
            AppColors.teamAColorLight.cgColor,
            AppColors.teamBColorLight.cgColor
        ]
        scoreGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        scoreGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }

    private func updateGradientCornerRadius() {
        let maskPath = UIBezierPath(roundedRect: scoreContainer.bounds, cornerRadius: 16)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        scoreGradientLayer.mask = maskLayer
    }

    // MARK: - Animations

    private func animateIn() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }

        // Trophy bounce animation
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.trophyImageView.transform = .identity
        }

        // Continuous trophy pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            UIView.animate(withDuration: 1.0, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
                self.trophyImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        trophyImageView.layer.removeAllAnimations()

        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
            self.view.backgroundColor = .clear
        }, completion: { _ in
            completion()
        })
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        animateOut {
            self.dismiss(animated: false)
        }
    }

    @objc private func newGameTapped() {
        animateOut {
            self.dismiss(animated: false) {
                self.delegate?.winnerViewControllerDidTapNewGame(self)
            }
        }
    }
}
