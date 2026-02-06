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
    private let homeRepository: HomeRepositoryProtocol?
    private let networkMonitor: (any NetworkConnectivityProviding)?
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
        searchHistoryRepository: SearchHistoryRepositoryProtocol,
        homeRepository: HomeRepositoryProtocol? = nil,
        networkMonitor: (any NetworkConnectivityProviding)? = nil
    ) {
        self.homeService = homeService
        self.searchHistoryRepository = searchHistoryRepository
        self.homeRepository = homeRepository
        self.networkMonitor = networkMonitor
        self.history = searchHistoryRepository.fetchTerms()
    }

    /// Fetches shops from the server once. All search is then done locally on this data.
    func load() async {
        isLoading = true
        loadError = nil
        
        // 1. Always load from cache first
        if let cached = homeRepository?.fetchCached() {
            allShops = cached.shops
            tagIdToTitle = buildTagIdToTitle(from: cached.tags)
        }
        
        // 2. If network not available, use cached data only
        guard networkMonitor?.isConnected ?? true else {
            isLoading = false
            // Perform search on cached data if query exists
            if trimmedQuery(query).count >= 3 {
                performSearch(for: query)
            }
            // If no cached data, show error
            if allShops.isEmpty {
                loadError = .noInternetConnection
            }
            return
        }
        
        // 3. Fetch from API
        let result = await homeService.fetchHome()
        isLoading = false
        
        switch result {
        case .success(let response):
            // 4. Save to DB, then update data
            try? homeRepository?.save(response)
            allShops = response.shops
            tagIdToTitle = buildTagIdToTitle(from: response.tags)
            if trimmedQuery(query).count >= 3 {
                performSearch(for: query)
            }
        case .failure(let error):
            // If we have cached data, don't show error
            if allShops.isEmpty {
                loadError = error
                allShops = []
                tagIdToTitle = [:]
            }
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

    func deleteHistory(_ terms: [String]) {
        for term in terms {
            try? searchHistoryRepository.delete(matching: term)
        }
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
