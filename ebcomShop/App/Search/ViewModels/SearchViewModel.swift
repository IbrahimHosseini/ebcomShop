//
//  SearchViewModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    private let homeService: HomeServiceProtocol
    private let historyKey = "search_history"
    private let maxHistoryCount = 10
    private var searchTask: Task<Void, Never>?

    var query = ""
    private(set) var allShops: [ShopModel] = []
    private(set) var results: [ShopModel] = []
    private(set) var history: [String] = []
    private(set) var isLoading = false
    private(set) var loadError: NetworkError?
    private(set) var shouldShowEmptyState = false

    init(homeService: HomeServiceProtocol) {
        self.homeService = homeService
        self.history = Self.loadHistory(key: historyKey)
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
        history.removeAll { $0.caseInsensitiveCompare(term) == .orderedSame }
        Self.saveHistory(history, key: historyKey)
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
        history.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        history.insert(trimmed, at: 0)

        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }

        Self.saveHistory(history, key: historyKey)
    }

    private func trimmedQuery(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func loadHistory(key: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    private static func saveHistory(_ history: [String], key: String) {
        UserDefaults.standard.set(history, forKey: key)
    }
}
