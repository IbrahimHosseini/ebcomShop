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

    /// Tag ID → title from last home response; used to resolve shop tag IDs for search and display.
    private var tagIdToTitle: [String: String] = [:]

    init(
        homeService: HomeServiceProtocol,
        searchHistoryRepository: SearchHistoryRepositoryProtocol
    ) {
        self.homeService = homeService
        self.searchHistoryRepository = searchHistoryRepository
        self.history = searchHistoryRepository.fetchTerms()
    }

    /// Fetches shops from the server once. All search is then done locally on this data.
    func load() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let result = await homeService.fetchHome()
        switch result {
        case .success(let response):
            allShops = response.shops
            tagIdToTitle = buildTagIdToTitle(from: response.tags)
            if trimmedQuery(query).count >= 3 {
                performSearch(for: query)
            }
        case .failure(let error):
            loadError = error
            allShops = []
            tagIdToTitle = [:]
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

    // MARK: - Search (local on fetched data only)
    // Source: allShops from server. Filter: title or tags. Result: matches for vertical list (logo, title, tags).

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

    /// Matches term against shop title or any related tag title (case-insensitive).
    private func matchesShop(_ shop: ShopModel, with term: String) -> Bool {
        let matchesTitle = shop.title.localizedCaseInsensitiveContains(term)
        let tagTitles = tagTitles(for: shop)
        let matchesTags = tagTitles.contains { $0.localizedCaseInsensitiveContains(term) }
        return matchesTitle || matchesTags
    }

    /// Resolved tag titles for a shop (tag IDs → titles using home response tags).
    func tagTitles(for shop: ShopModel) -> [String] {
        shop.tags?.compactMap { tagIdToTitle[$0] } ?? []
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

    private func buildTagIdToTitle(from tags: [TagModel]?) -> [String: String] {
        guard let tags else { return [:] }
        return Dictionary(
            uniqueKeysWithValues: tags.compactMap { tag in
                tag.title.map { (tag.id, $0) }
            }
        )
    }
}
