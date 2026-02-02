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
    private let searchHistoryRepository: SearchHistoryRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    var query = ""
    private(set) var allShops: [ShopModel] = []
    private(set) var results: [ShopModel] = []
    private(set) var history: [String] = []
    private(set) var isLoading = false
    private(set) var loadError: NetworkError?
    private(set) var shouldShowEmptyState = false

    init(
        homeService: HomeServiceProtocol,
        searchHistoryRepository: SearchHistoryRepositoryProtocol
    ) {
        self.homeService = homeService
        self.searchHistoryRepository = searchHistoryRepository
        self.history = searchHistoryRepository.fetchTerms()
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
            self?.performSearch(for: trimmed)
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
        try? searchHistoryRepository.delete(matching: term)
        history = searchHistoryRepository.fetchTerms()
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
        try? searchHistoryRepository.add(term: trimmed)
        history = searchHistoryRepository.fetchTerms()
    }

    private func trimmedQuery(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
