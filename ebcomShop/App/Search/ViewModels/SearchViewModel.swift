//
//  SearchViewModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SearchViewModel {
    private let homeService: HomeServiceProtocol
    private let modelContext: ModelContext
    private let maxHistoryCount = 10
    private var searchTask: Task<Void, Never>?

    var query = ""
    private(set) var allShops: [ShopModel] = []
    private(set) var results: [ShopModel] = []
    private(set) var history: [String] = []
    private(set) var isLoading = false
    private(set) var loadError: NetworkError?
    private(set) var shouldShowEmptyState = false

    init(homeService: HomeServiceProtocol, modelContext: ModelContext) {
        self.homeService = homeService
        self.modelContext = modelContext
        self.history = loadHistory()
    }

    func load() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let result = await homeService.fetchHome()
        switch result {
        case .success(let response):
            allShops = response.shops
            if trimmedQuery(query).count >= 3 {
                performSearch(for: query)
            }
        case .failure(let error):
            loadError = error
            allShops = []
        }
    }

    func onQueryChanged(_ newValue: String) {
        searchTask?.cancel()
        let trimmed = trimmedQuery(newValue)

        if trimmed.isEmpty {
            results = []
            shouldShowEmptyState = false
            return
        }

        if trimmed.count < 3 {
            results = []
            shouldShowEmptyState = false
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            await self?.performSearch(for: trimmed)
        }
    }

    func clearQuery() {
        query = ""
        results = []
        shouldShowEmptyState = false
        searchTask?.cancel()
    }

    func applyHistory(_ term: String) {
        query = term
        onQueryChanged(term)
    }

    func deleteHistory(_ term: String) {
        deleteHistoryEntries(matching: term)
        history = loadHistory()
    }

    private func performSearch(for term: String) {
        let trimmed = trimmedQuery(term)
        guard trimmedQuery(query) == trimmed else { return }
        guard trimmed.count >= 3 else {
            results = []
            shouldShowEmptyState = false
            return
        }

        let matches = allShops.filter { shop in
            matchesShop(shop, with: trimmed)
        }

        results = matches
        shouldShowEmptyState = matches.isEmpty

        if !matches.isEmpty {
            storeHistory(term: trimmed)
        }
    }

    private func matchesShop(_ shop: ShopModel, with term: String) -> Bool {
        let matchesTitle = shop.title.localizedCaseInsensitiveContains(term)
        let matchesTags = shop.tags?.contains { $0.localizedCaseInsensitiveContains(term) } ?? false
        return matchesTitle || matchesTags
    }

    private func storeHistory(term: String) {
        let trimmed = trimmedQuery(term)
        guard !trimmed.isEmpty else { return }
        deleteHistoryEntries(matching: trimmed)
        let entry = SearchHistoryEntry(term: trimmed, createdAt: Date())
        modelContext.insert(entry)
        trimHistoryToMaxCount()
        try? modelContext.save()
        history = loadHistory()
    }

    private func trimmedQuery(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadHistory() -> [String] {
        let descriptor = FetchDescriptor<SearchHistoryEntry>(
            sortBy: [SortDescriptor<SearchHistoryEntry>(\.createdAt, order: .reverse)]
        )
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.map(\.term)
    }

    private func deleteHistoryEntries(matching term: String) {
        let descriptor = FetchDescriptor<SearchHistoryEntry>()
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        for entry in entries where entry.term.caseInsensitiveCompare(term) == .orderedSame {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }

    private func trimHistoryToMaxCount() {
        let descriptor = FetchDescriptor<SearchHistoryEntry>(
            sortBy: [SortDescriptor<SearchHistoryEntry>(\.createdAt, order: .reverse)]
        )
        guard let entries = try? modelContext.fetch(descriptor), entries.count > maxHistoryCount else { return }
        let toDelete = entries.suffix(entries.count - maxHistoryCount)
        for entry in toDelete {
            modelContext.delete(entry)
        }
    }
}
