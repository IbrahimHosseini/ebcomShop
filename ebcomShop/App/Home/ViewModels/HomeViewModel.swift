//
//  HomeViewModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private let homeService: HomeServiceProtocol

    private(set) var sections: [HomeSectionItem] = []
    private(set) var faq: FAQPayload?
    private(set) var hasSearch: Bool = false
    private(set) var isLoading = false
    private(set) var loadError: NetworkError?

    init(homeService: HomeServiceProtocol) {
        self.homeService = homeService
    }

    func load() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let result = await homeService.fetchHome()

        switch result {
        case .success(let response):
            sections = mapSections(response)
            faq = response.home.faq
        case .failure(let error):
            loadError = error
            sections = []
            faq = nil
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
