//
//  ScoreHistoryView.swift
//  TPoint
//

import UIKit

final class ScoreHistoryView: UIView {

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
        return cell
    }
}

// MARK: - ScoreHistoryCell

final class ScoreHistoryCell: UITableViewCell {

    static let identifier = "ScoreHistoryCell"

    private let roundLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamAScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = "/"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let teamBScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemRed
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
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

        contentView.addSubview(roundLabel)
        contentView.addSubview(teamAScoreLabel)
        contentView.addSubview(separatorLabel)
        contentView.addSubview(teamBScoreLabel)
        contentView.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            roundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            roundLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roundLabel.widthAnchor.constraint(equalToConstant: 30),

            teamAScoreLabel.leadingAnchor.constraint(equalTo: roundLabel.trailingAnchor, constant: 8),
            teamAScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            teamAScoreLabel.widthAnchor.constraint(equalToConstant: 50),

            separatorLabel.leadingAnchor.constraint(equalTo: teamAScoreLabel.trailingAnchor, constant: 4),
            separatorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            teamBScoreLabel.leadingAnchor.constraint(equalTo: separatorLabel.trailingAnchor, constant: 4),
            teamBScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            teamBScoreLabel.widthAnchor.constraint(equalToConstant: 50),

            detailLabel.leadingAnchor.constraint(equalTo: teamBScoreLabel.trailingAnchor, constant: 12),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(round: Round, score: RoundScore) {
        roundLabel.text = "\(L10n.roundPrefix)\(round.roundNumber)"
        teamAScoreLabel.text = score.teamADisplay
        teamBScoreLabel.text = score.teamBDisplay

        var details: [String] = []
        if round.isOneTwoFinish, let team = round.oneTwoFinishTeam {
            details.append("\(team.displayName) \(L10n.oneTwo)")
        }
        for call in round.tichuCalls {
            let result = call.isSuccess ? "O" : "X"
            details.append("\(call.player.displayName) \(call.displayName)\(result)")
        }
        detailLabel.text = details.joined(separator: ", ")
    }
}
