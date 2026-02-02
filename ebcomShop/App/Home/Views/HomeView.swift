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

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task { viewModel = HomeViewModel(homeService: homeService) }
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: HomeViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
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
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.load()
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
        VStack(spacing: 12) {
            Text("خطا در بارگذاری")
                .typography(.headline)
            Text(viewModel.loadError?.localizedDescription ?? "")
                .typography(.footnote)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    HomeView()
        .environment(\.homeService, HomeServiceImpl())
}
