//
//  SearchHistoryRepository.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import SwiftData

@MainActor
final class SearchHistoryRepository: SearchHistoryRepositoryProtocol {
    private let modelContext: ModelContext
    private let maxHistoryCount: Int

    private static let createdAtDescending = SortDescriptor<SearchHistoryEntry>(\.createdAt, order: .reverse)

    init(modelContext: ModelContext, maxHistoryCount: Int = 10) {
        self.modelContext = modelContext
        self.maxHistoryCount = max(1, maxHistoryCount)
    }

    func fetchTerms() -> [String] {
        let descriptor = FetchDescriptor<SearchHistoryEntry>(sortBy: [Self.createdAtDescending])
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.map(\.term)
    }

    func add(term: String) throws {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        try delete(matching: trimmed)
        modelContext.insert(SearchHistoryEntry(term: trimmed, createdAt: Date()))
        trimToMaxCount()
        try modelContext.save()
    }

    func delete(matching term: String) throws {
        let descriptor = FetchDescriptor<SearchHistoryEntry>()
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        for entry in entries where entry.term.caseInsensitiveCompare(term) == .orderedSame {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }

    private func trimToMaxCount() {
        let descriptor = FetchDescriptor<SearchHistoryEntry>(sortBy: [Self.createdAtDescending])
        guard let entries = try? modelContext.fetch(descriptor), entries.count > maxHistoryCount else { return }
        for entry in entries.suffix(entries.count - maxHistoryCount) {
            modelContext.delete(entry)
        }
    }
}
