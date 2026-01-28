//
//  NewGameViewController.swift
//  TPoint
//

import UIKit

protocol NewGameViewControllerDelegate: AnyObject {
    func newGameViewControllerDidConfirm(_ controller: NewGameViewController)
}

final class NewGameViewController: UIViewController {

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
        let image = UIImage(systemName: "arrow.counterclockwise.circle.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = AppColors.failureColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scoreGradientLayer = CAGradientLayer()

    private let currentScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.failureColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    weak var delegate: NewGameViewControllerDelegate?
    private let teamAScore: Int
    private let teamBScore: Int

    // MARK: - Initialization

    init(teamAScore: Int, teamBScore: Int) {
        self.teamAScore = teamAScore
        self.teamBScore = teamBScore
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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Score container gradient
        scoreContainer.layer.insertSublayer(scoreGradientLayer, at: 0)

        let scoreStack = UIStackView(arrangedSubviews: [teamAScoreLabel, vsLabel, teamBScoreLabel])
        scoreStack.axis = .horizontal
        scoreStack.distribution = .equalCentering
        scoreStack.alignment = .center
        scoreStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 12
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(currentScoreLabel)
        containerView.addSubview(scoreContainer)
        scoreContainer.addSubview(scoreStack)
        containerView.addSubview(buttonsStack)

        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        containerView.alpha = 0

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 56),
            iconImageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            currentScoreLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            currentScoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            scoreContainer.topAnchor.constraint(equalTo: currentScoreLabel.bottomAnchor, constant: 8),
            scoreContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            scoreContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            scoreContainer.heightAnchor.constraint(equalToConstant: 60),

            scoreStack.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreStack.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            scoreStack.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor, constant: 24),
            scoreStack.trailingAnchor.constraint(equalTo: scoreContainer.trailingAnchor, constant: -24),

            buttonsStack.topAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: 20),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 48),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }

    private func configureContent() {
        titleLabel.text = L10n.newGame
        messageLabel.text = L10n.newGameConfirm
        currentScoreLabel.text = L10n.currentScore
        cancelButton.setTitle(L10n.cancel, for: .normal)
        confirmButton.setTitle(L10n.newGame, for: .normal)

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
        let maskPath = UIBezierPath(roundedRect: scoreContainer.bounds, cornerRadius: 12)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        scoreGradientLayer.mask = maskLayer
    }

    // MARK: - Animations

    private func animateIn() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
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

    @objc private func confirmTapped() {
        // Button animation
        UIView.animate(withDuration: 0.1, animations: {
            self.confirmButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.confirmButton.transform = .identity
            }
        }

        animateOut {
            self.dismiss(animated: false) {
                self.delegate?.newGameViewControllerDidConfirm(self)
            }
        }
    }
}
