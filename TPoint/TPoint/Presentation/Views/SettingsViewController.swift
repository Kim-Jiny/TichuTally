//
//  SettingsViewController.swift
//  TPoint
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsDidChangeTargetScore(_ score: Int)
    func settingsDidChangeTheme(_ mode: ThemeMode)
    func settingsDidChangeTeamNames(_ teamAName: String, _ teamBName: String)
}

final class SettingsViewController: UIViewController {

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackgroundElevated
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.textSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Theme section
    private let themeSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let themeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: [L10n.themeSystem, L10n.themeLight, L10n.themeDark])
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    // Target score section
    private let scoreSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var scoreButtons: [UIButton] = []
    private let scorePresets = [500, 1000, 1500, 2000]

    private let customScoreContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.surfaceLight
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let customScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let customScoreTextField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16, weight: .semibold)
        field.textColor = AppColors.textPrimary
        field.keyboardType = .numberPad
        field.textAlignment = .right
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    // Team names section
    private let teamNamesSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamANameField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16)
        field.textColor = AppColors.textPrimary
        field.borderStyle = .roundedRect
        field.backgroundColor = AppColors.surfaceLight
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let teamBNameField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16)
        field.textColor = AppColors.textPrimary
        field.borderStyle = .roundedRect
        field.backgroundColor = AppColors.surfaceLight
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.successColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    weak var delegate: SettingsViewControllerDelegate?
    private var currentTargetScore: Int
    private var currentThemeMode: ThemeMode
    private let initialTeamAName: String
    private let initialTeamBName: String

    // MARK: - Initialization

    init(targetScore: Int, themeMode: ThemeMode, teamAName: String, teamBName: String) {
        self.currentTargetScore = targetScore
        self.currentThemeMode = themeMode
        self.initialTeamAName = teamAName
        self.initialTeamBName = teamBName
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
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Localized texts
        titleLabel.text = L10n.settings
        themeSectionLabel.text = L10n.theme
        scoreSectionLabel.text = L10n.targetScore
        customScoreLabel.text = L10n.customScore
        teamNamesSectionLabel.text = L10n.teamNames
        teamANameField.placeholder = L10n.teamA
        teamBNameField.placeholder = L10n.teamB
        teamANameField.text = initialTeamAName
        teamBNameField.text = initialTeamBName
        saveButton.setTitle(L10n.save, for: .normal)

        // Create score preset buttons
        for score in scorePresets {
            let button = UIButton(type: .system)
            button.setTitle("\(score)", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1.5
            button.tag = score
            button.addTarget(self, action: #selector(scorePresetTapped(_:)), for: .touchUpInside)
            scoreButtons.append(button)
            scoreButtonsStack.addArrangedSubview(button)
        }

        customScoreContainer.addSubview(customScoreLabel)
        customScoreContainer.addSubview(customScoreTextField)

        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(themeSectionLabel)
        containerView.addSubview(themeSegment)
        containerView.addSubview(scoreSectionLabel)
        containerView.addSubview(scoreButtonsStack)
        containerView.addSubview(customScoreContainer)
        containerView.addSubview(teamNamesSectionLabel)
        containerView.addSubview(teamANameField)
        containerView.addSubview(teamBNameField)
        containerView.addSubview(saveButton)

        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        containerView.alpha = 0

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            // Theme section
            themeSectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            themeSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            themeSegment.topAnchor.constraint(equalTo: themeSectionLabel.bottomAnchor, constant: 8),
            themeSegment.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            themeSegment.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            // Score section
            scoreSectionLabel.topAnchor.constraint(equalTo: themeSegment.bottomAnchor, constant: 24),
            scoreSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            scoreButtonsStack.topAnchor.constraint(equalTo: scoreSectionLabel.bottomAnchor, constant: 8),
            scoreButtonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scoreButtonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            scoreButtonsStack.heightAnchor.constraint(equalToConstant: 40),

            // Custom score
            customScoreContainer.topAnchor.constraint(equalTo: scoreButtonsStack.bottomAnchor, constant: 12),
            customScoreContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            customScoreContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            customScoreContainer.heightAnchor.constraint(equalToConstant: 44),

            customScoreLabel.leadingAnchor.constraint(equalTo: customScoreContainer.leadingAnchor, constant: 12),
            customScoreLabel.centerYAnchor.constraint(equalTo: customScoreContainer.centerYAnchor),

            customScoreTextField.trailingAnchor.constraint(equalTo: customScoreContainer.trailingAnchor, constant: -12),
            customScoreTextField.centerYAnchor.constraint(equalTo: customScoreContainer.centerYAnchor),
            customScoreTextField.widthAnchor.constraint(equalToConstant: 80),

            // Team names section
            teamNamesSectionLabel.topAnchor.constraint(equalTo: customScoreContainer.bottomAnchor, constant: 20),
            teamNamesSectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            teamANameField.topAnchor.constraint(equalTo: teamNamesSectionLabel.bottomAnchor, constant: 8),
            teamANameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            teamANameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            teamANameField.heightAnchor.constraint(equalToConstant: 40),

            teamBNameField.topAnchor.constraint(equalTo: teamANameField.bottomAnchor, constant: 8),
            teamBNameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            teamBNameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            teamBNameField.heightAnchor.constraint(equalToConstant: 40),

            // Save button
            saveButton.topAnchor.constraint(equalTo: teamBNameField.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        themeSegment.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        customScoreTextField.addTarget(self, action: #selector(customScoreChanged), for: .editingChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }

    private func updateUI() {
        themeSegment.selectedSegmentIndex = currentThemeMode.rawValue
        customScoreTextField.text = "\(currentTargetScore)"
        updateScoreButtonsSelection()
    }

    private func updateScoreButtonsSelection() {
        for button in scoreButtons {
            let isSelected = button.tag == currentTargetScore
            button.backgroundColor = isSelected ? AppColors.teamAColor : .clear
            button.setTitleColor(isSelected ? .white : AppColors.teamAColor, for: .normal)
            button.layer.borderColor = AppColors.teamAColor.cgColor
        }
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

    @objc private func closeTapped() {
        animateOut {
            self.dismiss(animated: false)
        }
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            closeTapped()
        }
    }

    @objc private func themeChanged() {
        currentThemeMode = ThemeMode(rawValue: themeSegment.selectedSegmentIndex) ?? .system
    }

    @objc private func scorePresetTapped(_ sender: UIButton) {
        currentTargetScore = sender.tag
        customScoreTextField.text = "\(currentTargetScore)"
        updateScoreButtonsSelection()
    }

    @objc private func customScoreChanged() {
        if let text = customScoreTextField.text, let score = Int(text), score > 0 {
            currentTargetScore = score
            updateScoreButtonsSelection()
        }
    }

    @objc private func saveTapped() {
        // 설정 화면을 먼저 닫은 뒤 델리게이트를 호출해야, 목표 점수 변경으로 게임이 종료된 경우
        // 승자 다이얼로그를 present-while-presented 없이 띄울 수 있음 (다른 다이얼로그와 동일 패턴)
        animateOut {
            self.dismiss(animated: false) {
                // 팀 이름을 먼저 적용해야, 목표 점수 변경으로 게임이 종료될 때
                // 승자 다이얼로그/공유 이미지에 새 이름이 반영됨
                self.delegate?.settingsDidChangeTeamNames(
                    self.teamANameField.text ?? "",
                    self.teamBNameField.text ?? ""
                )
                self.delegate?.settingsDidChangeTargetScore(self.currentTargetScore)
                self.delegate?.settingsDidChangeTheme(self.currentThemeMode)
            }
        }
    }
}
