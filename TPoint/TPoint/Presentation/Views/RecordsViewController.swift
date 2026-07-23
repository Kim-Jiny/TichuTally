//
//  RecordsViewController.swift
//  TPoint
//
//  지난 게임 기록 + 통계 (세그먼트 전환)
//

import UIKit

final class RecordsViewController: UIViewController {

    private enum Mode: Int { case history, stats }
    private var mode: Mode = .history

    private let history: [GameHistoryEntry]
    private let stats: GameStats
    var onClearHistory: (() -> Void)?

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let segmented: UISegmentedControl
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd HH:mm"
        return f
    }()

    private var statRows: [(label: String, value: String, color: UIColor?)] = []

    init(history: [GameHistoryEntry]) {
        self.history = history
        self.stats = GameStats.from(history)
        self.segmented = UISegmentedControl(items: [L10n.tabHistory, L10n.tabStats])
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.surfaceLight
        buildStatRows()
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
        updateEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func buildStatRows() {
        func pct(_ r: Double) -> String { "\(Int(r * 100))%" }
        statRows = [
            (L10n.statTotalGames, "\(stats.totalGames)", nil),
            (L10n.statWinRate, "A \(pct(stats.teamAWinRate)) · B \(pct(stats.teamBWinRate))", nil),
            (L10n.statAvgRounds, String(format: "%.1f", stats.avgRounds), nil),
            (L10n.statSmallTichu, "\(stats.smallTichuSuccess)/\(stats.smallTichuAttempts) (\(pct(stats.smallTichuRate)))", nil),
            (L10n.statLargeTichu, "\(stats.largeTichuSuccess)/\(stats.largeTichuAttempts) (\(pct(stats.largeTichuRate)))", AppColors.largeTichuColor),
            (L10n.statOneTwo, "\(stats.oneTwoFinishCount)", nil),
            (L10n.statHighestScore, "\(stats.highestScore)", nil)
        ]
    }

    private func setupUI() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)

        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        backButton.tintColor = AppColors.textSecondary
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = L10n.records
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        clearButton.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        clearButton.tintColor = AppColors.textSecondary
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.isHidden = history.isEmpty
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = L10n.noHistory
        emptyLabel.textColor = AppColors.textHint
        emptyLabel.font = .systemFont(ofSize: 15)
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(clearButton)
        view.addSubview(segmented)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 12),
            backButton.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            clearButton.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 44),
            clearButton.heightAnchor.constraint(equalToConstant: 44),

            segmented.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            segmented.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateEmptyState() {
        emptyLabel.isHidden = !(mode == .history && history.isEmpty)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func segmentChanged() {
        mode = Mode(rawValue: segmented.selectedSegmentIndex) ?? .history
        clearButton.isHidden = (mode != .history) || history.isEmpty
        updateEmptyState()
        tableView.reloadData()
    }

    @objc private func clearTapped() {
        let alert = UIAlertController(title: L10n.clearHistory,
                                      message: L10n.clearHistoryConfirm,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.confirm, style: .destructive) { [weak self] _ in
            self?.onClearHistory?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func winnerBadge(_ winner: TeamType?) -> UIView {
        let text: String
        let color: UIColor
        switch winner {
        case .teamA: text = TeamType.teamA.shortName; color = AppColors.teamAColor
        case .teamB: text = TeamType.teamB.shortName; color = AppColors.teamBColor
        case .none:  text = L10n.draw; color = AppColors.textHint
        }
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.sizeToFit()
        let pad: CGFloat = 10
        let container = UIView(frame: CGRect(x: 0, y: 0, width: label.bounds.width + pad * 2, height: 28))
        container.backgroundColor = color.withAlphaComponent(0.15)
        container.layer.cornerRadius = 8
        label.frame = container.bounds
        container.addSubview(label)
        return container
    }

    private func scoreAttributed(_ entry: GameHistoryEntry) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 18, weight: .bold)
        let s = NSMutableAttributedString()
        s.append(NSAttributedString(string: "\(entry.teamAScore)",
            attributes: [.foregroundColor: AppColors.teamAColor, .font: font]))
        s.append(NSAttributedString(string: " : ",
            attributes: [.foregroundColor: AppColors.textSecondary, .font: font]))
        s.append(NSAttributedString(string: "\(entry.teamBScore)",
            attributes: [.foregroundColor: AppColors.teamBColor, .font: font]))
        return s
    }
}

extension RecordsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mode == .history ? history.count : statRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mode == .stats {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let row = statRows[indexPath.row]
            cell.textLabel?.text = row.label
            cell.textLabel?.textColor = AppColors.textSecondary
            cell.textLabel?.font = .systemFont(ofSize: 15)
            cell.detailTextLabel?.text = row.value
            cell.detailTextLabel?.textColor = row.color ?? AppColors.textPrimary
            cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let entry = history[indexPath.row]
            cell.textLabel?.attributedText = scoreAttributed(entry)
            cell.detailTextLabel?.text = "\(dateFormatter.string(from: entry.completedAt))  ·  \(L10n.roundsCount(entry.roundCount))"
            cell.detailTextLabel?.textColor = AppColors.textHint
            cell.detailTextLabel?.font = .systemFont(ofSize: 12)
            cell.accessoryView = winnerBadge(entry.winner)
            return cell
        }
    }
}
