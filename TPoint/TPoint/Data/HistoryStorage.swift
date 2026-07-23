//
//  HistoryStorage.swift
//  TPoint
//
//  완료된 게임 기록 목록을 파일에 JSON으로 보관한다.
//

import Foundation

final class HistoryStorage {

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("history.json")
    }()

    /// 최신순으로 정렬된 기록 목록을 반환한다.
    func load() -> [GameHistoryEntry] {
        guard let data = try? Data(contentsOf: fileURL),
              let entries = try? JSONDecoder().decode([GameHistoryEntry].self, from: data) else {
            return []
        }
        return entries.sorted { $0.completedAt > $1.completedAt }
    }

    func append(_ entry: GameHistoryEntry) {
        var entries = load()
        entries.append(entry)
        save(entries.sorted { $0.completedAt > $1.completedAt })
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func save(_ entries: [GameHistoryEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ HistoryStorage save failed: \(error)")
        }
    }
}
