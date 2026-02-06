//
//  HomeViewModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let homeService: HomeServiceProtocol
    private let homeRepository: HomeRepositoryProtocol?
    private let networkMonitor: NetworkMonitor?

    private(set) var sections: [HomeSectionItem] = []
    private(set) var faq: FAQPayload?
    private(set) var hasSearch: Bool = false
    private(set) var isLoading = false
    private(set) var loadError: NetworkError?

    init(
        homeService: HomeServiceProtocol,
        homeRepository: HomeRepositoryProtocol? = nil,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.homeService = homeService
        self.homeRepository = homeRepository
        self.networkMonitor = networkMonitor
    }

    func load() async {
        isLoading = true
        loadError = nil
        
        // 1. Always load from cache first
        if let cached = homeRepository?.fetchCached() {
            sections = mapSections(cached)
            faq = cached.home.faq
        }
        
        // 2. If network not available, use cached data only
        guard networkMonitor?.isConnected ?? true else {
            isLoading = false
            // If no cached data, show error
            if sections.isEmpty {
                loadError = .noInternetConnection
            }
            return
        }
        
        // 3. Fetch from API
        let result = await homeService.fetchHome()
        isLoading = false

        switch result {
        case .success(let response):
            // 4. Save to DB, then update UI
            try? homeRepository?.save(response)
            sections = mapSections(response)
            faq = response.home.faq
        case .failure(let error):
            // If we have cached data, don't show error
            if sections.isEmpty {
                loadError = error
                sections = []
                faq = nil
            }
        }
    }

    private func mapSections(_ response: HomeResponse) -> [HomeSectionItem] {
        let categoryById = Dictionary(uniqueKeysWithValues: response.categories.map { ($0.id, $0) })
        let shopById = Dictionary(uniqueKeysWithValues: response.shops.map { ($0.id, $0) })
        let bannerById = Dictionary(uniqueKeysWithValues: response.banners.map { ($0.id, $0) })
        
        hasSearch = response.home.search ?? false

        return response.home.sections.map { payload in
            switch payload.type {
            case .category:
                let items = payload.list.compactMap { categoryById[$0] }
                return .category(title: payload.title, items: items)
            case .banner:
                let items = payload.list.compactMap { bannerById[$0] }
                return .banner(items: items)
            case .shop:
                let items = payload.list.compactMap { shopById[$0] }
                return .shop(title: payload.title, items: items)
            case .fixedBanner:
                let items = payload.list.compactMap { bannerById[$0] }
                return .fixedBanner(title: payload.title, items: items)
            }
        }
    }
}
