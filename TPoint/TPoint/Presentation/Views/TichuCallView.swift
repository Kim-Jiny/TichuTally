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

    private let playerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let smallTichuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("S", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let largeTichuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("L", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let successButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("O", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.setTitleColor(.systemGray3, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    let player: Player
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

    // MARK: - Initialization

    init(player: Player) {
        self.player = player
        super.init(frame: .zero)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        playerLabel.text = player.displayName
        playerLabel.textColor = player.team == .teamA ? .systemBlue : .systemRed

        addSubview(playerLabel)
        addSubview(smallTichuButton)
        addSubview(largeTichuButton)
        addSubview(successButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 32),

            playerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            smallTichuButton.leadingAnchor.constraint(equalTo: playerLabel.trailingAnchor, constant: 6),
            smallTichuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            smallTichuButton.widthAnchor.constraint(equalToConstant: 28),
            smallTichuButton.heightAnchor.constraint(equalToConstant: 28),

            largeTichuButton.leadingAnchor.constraint(equalTo: smallTichuButton.trailingAnchor, constant: 4),
            largeTichuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            largeTichuButton.widthAnchor.constraint(equalToConstant: 28),
            largeTichuButton.heightAnchor.constraint(equalToConstant: 28),

            successButton.leadingAnchor.constraint(equalTo: largeTichuButton.trailingAnchor, constant: 4),
            successButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            successButton.widthAnchor.constraint(equalToConstant: 28),
            successButton.heightAnchor.constraint(equalToConstant: 28),
            successButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])

        updateButtonStates()
    }

    private func setupActions() {
        smallTichuButton.addTarget(self, action: #selector(smallTichuTapped), for: .touchUpInside)
        largeTichuButton.addTarget(self, action: #selector(largeTichuTapped), for: .touchUpInside)
        successButton.addTarget(self, action: #selector(successTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func smallTichuTapped() {
        if selectedType == .small {
            selectedType = nil
        } else {
            selectedType = .small
        }
    }

    @objc private func largeTichuTapped() {
        if selectedType == .large {
            selectedType = nil
        } else {
            selectedType = .large
        }
    }

    @objc private func successTapped() {
        guard selectedType != nil else { return }
        isSuccess.toggle()
    }

    // MARK: - Private Methods

    private func updateButtonStates() {
        let isSmallSelected = selectedType == .small
        let isLargeSelected = selectedType == .large
        let hasTichuCall = selectedType != nil

        // 스몰 티츄 버튼
        smallTichuButton.backgroundColor = isSmallSelected ? .systemBlue : .clear
        smallTichuButton.setTitleColor(isSmallSelected ? .white : .systemBlue, for: .normal)
        smallTichuButton.layer.borderColor = isSmallSelected ? UIColor.systemBlue.cgColor : UIColor.systemGray3.cgColor

        // 라지 티츄 버튼
        largeTichuButton.backgroundColor = isLargeSelected ? .systemOrange : .clear
        largeTichuButton.setTitleColor(isLargeSelected ? .white : .systemOrange, for: .normal)
        largeTichuButton.layer.borderColor = isLargeSelected ? UIColor.systemOrange.cgColor : UIColor.systemGray3.cgColor

        // 성공 버튼
        if hasTichuCall {
            if isSuccess {
                successButton.backgroundColor = .systemGreen
                successButton.setTitleColor(.white, for: .normal)
                successButton.setTitle("O", for: .normal)
                successButton.layer.borderColor = UIColor.systemGreen.cgColor
            } else {
                successButton.backgroundColor = .systemRed
                successButton.setTitleColor(.white, for: .normal)
                successButton.setTitle("X", for: .normal)
                successButton.layer.borderColor = UIColor.systemRed.cgColor
            }
            successButton.isEnabled = true
        } else {
            successButton.backgroundColor = .clear
            successButton.setTitleColor(.systemGray3, for: .normal)
            successButton.setTitle("-", for: .normal)
            successButton.layer.borderColor = UIColor.systemGray3.cgColor
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

    var hasTichuCall: Bool {
        selectedType != nil
    }

    var currentTichuType: TichuType? {
        selectedType
    }
}
