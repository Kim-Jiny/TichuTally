//
//  ScoreHistoryView.swift
//  TPoint
//

import UIKit

protocol ScoreHistoryViewDelegate: AnyObject {
    func scoreHistoryView(_ view: ScoreHistoryView, didDeleteRoundAt index: Int)
}

final class ScoreHistoryView: UIView {

    // MARK: - Delegate

    weak var delegate: ScoreHistoryViewDelegate?

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.roundHistory
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ScoreHistoryCell.self, forCellReuseIdentifier: ScoreHistoryCell.identifier)
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.noRecords
        label.font = .systemFont(ofSize: 14)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    private var rounds: [Round] = []
    private var scores: [RoundScore] = []

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor

        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(emptyLabel)

        tableView.dataSource = self
        tableView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20)
        ])
    }

    // MARK: - Public Methods

    func updateHistory(rounds: [Round], scores: [RoundScore]) {
        self.rounds = rounds
        self.scores = scores
        tableView.reloadData()
        emptyLabel.isHidden = !rounds.isEmpty
    }
}

// MARK: - UITableViewDataSource

extension ScoreHistoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rounds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScoreHistoryCell.identifier, for: indexPath) as? ScoreHistoryCell else {
            return UITableViewCell()
        }

        let round = rounds[indexPath.row]
        let score = scores[indexPath.row]
        cell.configure(round: round, score: score)
        cell.onDeleteTapped = { [weak self] in
            guard let self = self else { return }
            self.delegate?.scoreHistoryView(self, didDeleteRoundAt: indexPath.row)
        }
        return cell
    }
}


// MARK: - ScoreHistoryCell

final class ScoreHistoryCell: UITableViewCell {

    static let identifier = "ScoreHistoryCell"

    // MARK: - Callback

    var onDeleteTapped: (() -> Void)?

    // MARK: - UI Components

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .tertiaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 라운드 번호
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 점수 컨테이너 (고정 너비)
    private let scoreContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemRed
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 세부내용 (오른쪽 정렬, 고정 위치)
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(deleteButton)
        contentView.addSubview(roundLabel)
        contentView.addSubview(scoreContainer)
        contentView.addSubview(detailLabel)

        scoreContainer.addSubview(teamAScoreLabel)
        scoreContainer.addSubview(separatorLabel)
        scoreContainer.addSubview(teamBScoreLabel)

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // 삭제 버튼 (왼쪽 끝)
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),

            // 라운드 번호 (삭제 버튼 옆, 너비 32)
            roundLabel.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 4),
            roundLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roundLabel.widthAnchor.constraint(equalToConstant: 32),

            // 점수 컨테이너 (라운드 옆, 고정 너비 100)
            scoreContainer.leadingAnchor.constraint(equalTo: roundLabel.trailingAnchor, constant: 4),
            scoreContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scoreContainer.widthAnchor.constraint(equalToConstant: 100),
            scoreContainer.heightAnchor.constraint(equalToConstant: 20),

            // 점수 컨테이너 내부
            teamAScoreLabel.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor),
            teamAScoreLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            teamAScoreLabel.widthAnchor.constraint(equalToConstant: 42),

            separatorLabel.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            separatorLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            separatorLabel.widthAnchor.constraint(equalToConstant: 16),

            teamBScoreLabel.trailingAnchor.constraint(equalTo: scoreContainer.trailingAnchor),
            teamBScoreLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            teamBScoreLabel.widthAnchor.constraint(equalToConstant: 42),

            // 세부내용 (오른쪽 정렬)
            detailLabel.leadingAnchor.constraint(equalTo: scoreContainer.trailingAnchor, constant: 8),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    func configure(round: Round, score: RoundScore) {
        roundLabel.text = "R\(round.roundNumber)"
        teamAScoreLabel.text = score.teamADisplay
        teamBScoreLabel.text = score.teamBDisplay

        var details: [String] = []
        if round.isOneTwoFinish, let team = round.oneTwoFinishTeam {
            details.append("\(team.shortName) 1-2")
        }
        for call in round.tichuCalls {
            let result = call.isSuccess ? "O" : "X"
            let tichuShort = call.isLarge ? "L" : "S"
            details.append("\(call.player.displayName)\(tichuShort)\(result)")
        }
        detailLabel.text = details.joined(separator: " ")
    }
}
