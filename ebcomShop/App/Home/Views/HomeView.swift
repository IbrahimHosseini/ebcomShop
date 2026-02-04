//
//  HomeView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.homeService) private var homeService
    @State private var viewModel: HomeViewModel?
    @State private var showSeachView: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel: viewModel)
                } else {
                    AppProgressView(style: .fullScreen)
                        .task { viewModel = HomeViewModel(homeService: homeService) }
                }
            }
            .background(Color.background)
        }
    }

    @ViewBuilder
    private func content(viewModel: HomeViewModel) -> some View {
        VStack(spacing: 0) {
            headerView(viewModel.hasSearch)
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading {
                        AppProgressView(style: .inline(verticalPadding: 40))
                    } else if viewModel.loadError != nil {
                        errorView(viewModel: viewModel)
                    } else {
                        ForEach(Array(viewModel.sections.enumerated()), id: \.offset) { _, section in
                            sectionView(for: section)
                        }
                        if let faq = viewModel.faq {
                            FAQSectionView(faq: faq)
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showSeachView) {
            SearchView()
        }
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.load()
        }
    }

    private func headerView(_ hasSearch: Bool) -> some View {
        
        NavigationHeaderWithSearch(
            showsSearch: hasSearch,
            placeholder: "جستجو فروشگاه یا برند...") {
                showSeachView = true
            }
    }

    @ViewBuilder
    private func sectionView(for section: HomeSectionItem) -> some View {
        switch section {
        case .category(let title, let items):
            CategorySectionView(title: title, items: items)
        case .banner(let items):
            BannerSectionView(items: items)
        case .shop(let title, let items):
            ShopSectionView(title: title, items: items)
        case .fixedBanner(let title, let items):
            FixedBannerSectionView(title: title, items: items)
        }
    }

    private func errorView(viewModel: HomeViewModel) -> some View {
        ErrorStateView(
            title: "خطا در بارگذاری",
            message: viewModel.loadError?.localizedDescription,
            onRetry: {
                await viewModel.load()
            }
        )
    }
}

#Preview {
    HomeView()
        .environment(\.homeService, HomeServiceImpl())
}
