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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tichuSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var tichuCallViews: [TichuCallView] = []

    private let oneTwoFinishLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
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
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "A"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .systemBlue
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

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "B"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamAScoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "50"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreSeparatorLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "50"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addRoundButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
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

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12

        // Localized texts
        titleLabel.text = L10n.roundInputTitle
        tichuSectionLabel.text = L10n.tichuSectionTitle
        oneTwoFinishLabel.text = L10n.oneTwoFinish
        scoreLabel.text = L10n.cardScore
        addRoundButton.setTitle(L10n.addRound, for: .normal)

        // 티츄 콜 뷰 생성
        for player in Player.allPlayers {
            let callView = TichuCallView(player: player)
            callView.delegate = self
            callView.translatesAutoresizingMaskIntoConstraints = false
            tichuCallViews.append(callView)
        }

        // A팀 (플레이어 1, 2)
        let tichuStackA = UIStackView(arrangedSubviews: [tichuCallViews[0], tichuCallViews[1]])
        tichuStackA.axis = .vertical
        tichuStackA.spacing = 4
        tichuStackA.translatesAutoresizingMaskIntoConstraints = false

        // B팀 (플레이어 1, 2)
        let tichuStackB = UIStackView(arrangedSubviews: [tichuCallViews[2], tichuCallViews[3]])
        tichuStackB.axis = .vertical
        tichuStackB.spacing = 4
        tichuStackB.translatesAutoresizingMaskIntoConstraints = false

        // 전체 티츄 영역
        let tichuContainer = UIStackView(arrangedSubviews: [tichuStackA, tichuStackB])
        tichuContainer.axis = .horizontal
        tichuContainer.distribution = .fillEqually
        tichuContainer.spacing = 8
        tichuContainer.translatesAutoresizingMaskIntoConstraints = false

        // 점수 표시
        let scoreDisplayStack = UIStackView(arrangedSubviews: [teamAScoreValueLabel, scoreSeparatorLabel, teamBScoreValueLabel])
        scoreDisplayStack.axis = .horizontal
        scoreDisplayStack.distribution = .fillEqually
        scoreDisplayStack.translatesAutoresizingMaskIntoConstraints = false

        // 슬라이더
        let sliderStack = UIStackView(arrangedSubviews: [teamAScoreLabel, scoreSlider, teamBScoreLabel])
        sliderStack.axis = .horizontal
        sliderStack.spacing = 8
        sliderStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(tichuSectionLabel)
        addSubview(tichuContainer)
        addSubview(oneTwoFinishLabel)
        addSubview(oneTwoSegment)
        addSubview(scoreLabel)
        addSubview(scoreDisplayStack)
        addSubview(sliderStack)
        addSubview(addRoundButton)

        NSLayoutConstraint.activate([
            // 타이틀
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            // 티츄 섹션
            tichuSectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tichuSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            tichuContainer.topAnchor.constraint(equalTo: tichuSectionLabel.bottomAnchor, constant: 8),
            tichuContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tichuContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // 원투 피니시
            oneTwoFinishLabel.topAnchor.constraint(equalTo: tichuContainer.bottomAnchor, constant: 12),
            oneTwoFinishLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            oneTwoSegment.topAnchor.constraint(equalTo: oneTwoFinishLabel.bottomAnchor, constant: 6),
            oneTwoSegment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            oneTwoSegment.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // 카드 점수
            scoreLabel.topAnchor.constraint(equalTo: oneTwoSegment.bottomAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            scoreDisplayStack.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            scoreDisplayStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scoreDisplayStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            sliderStack.topAnchor.constraint(equalTo: scoreDisplayStack.bottomAnchor, constant: 4),
            sliderStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sliderStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // 버튼
            addRoundButton.topAnchor.constraint(equalTo: sliderStack.bottomAnchor, constant: 16),
            addRoundButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            addRoundButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addRoundButton.heightAnchor.constraint(equalToConstant: 44),
            addRoundButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func setupActions() {
        scoreSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        oneTwoSegment.addTarget(self, action: #selector(oneTwoSegmentChanged), for: .valueChanged)
        addRoundButton.addTarget(self, action: #selector(addRoundTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func sliderValueChanged() {
        // 5점 단위로 스냅
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

        delegate?.roundInputView(self, didChangeOneTwoFinish: enabled, team: team)
    }

    @objc private func addRoundTapped() {
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

        for callView in tichuCallViews {
            callView.reset()
        }
    }

    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }
}

// MARK: - TichuCallViewDelegate

extension RoundInputView: TichuCallViewDelegate {
    func tichuCallView(_ view: TichuCallView, didUpdateCall type: TichuType?, isSuccess: Bool) {
        // 현재 플레이어 상태 업데이트
        delegate?.roundInputView(self, didChangeTichuCall: view.player, type: type, isSuccess: isSuccess)

        // 성공으로 변경된 경우, 다른 티츄 콜들은 자동으로 실패 처리
        if isSuccess && type != nil {
            for otherView in tichuCallViews where otherView !== view {
                if otherView.hasTichuCall {
                    otherView.setSuccess(false, silent: true)
                    // ViewModel에도 실패 상태 전달
                    if let otherType = otherView.currentTichuType {
                        delegate?.roundInputView(self, didChangeTichuCall: otherView.player, type: otherType, isSuccess: false)
                    }
                }
            }
        }
    }
}
