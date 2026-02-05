//
//  SearchView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Observation
import SwiftUI

struct SearchView: View {
    @Environment(\.homeService) private var homeService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SearchViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                AppProgressView(style: .fullScreen)
                    .task {
                        viewModel = SearchViewModel(
                            homeService: homeService,
                            searchHistoryRepository: SearchHistoryRepository(modelContext: modelContext)
                        )
                    }
            }
        }
        .navBarToolbar(title: "جستجو")
    }

    @ViewBuilder
    private func content(viewModel: SearchViewModel) -> some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            searchBar(viewModel: viewModel)
            if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                SearchHistorySectionView(
                    history: viewModel.history,
                    onDelete: { viewModel.deleteHistory(viewModel.history) },
                    onSelectTerm: { viewModel.applyHistory($0) }
                )
            }
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading {
                        AppProgressView(style: .inline(verticalPadding: 32))
                    } else if viewModel.loadError != nil {
                        errorView
                    } else if viewModel.shouldShowEmptyState {
                        emptyStateView
                    } else {
                        resultsList(viewModel: viewModel)
                    }
                }
                .padding(.top, 28)
            }
        }
        .background(Color.background)
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.query) { _, newValue in
            viewModel.onQueryChanged(newValue)
        }
    }

    private func searchBar(@Bindable viewModel: SearchViewModel) -> some View {
        SearchBarView(
            placeholder: "جستجو فروشگاه یا برند...",
            text: $viewModel.query,
            onClear: { viewModel.clearQuery() }
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    /// Vertical list of found shops (logo, title, tags). Data comes from local filter on fetched shops only.
    @ViewBuilder
    private func resultsList(@Bindable viewModel: SearchViewModel) -> some View {
        if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 {
            
            SearchTextResultView(query: viewModel.query)
            
            ForEach(viewModel.results) { shop in
                SearchResultRowView(shop: shop, tagTitles: viewModel.tagTitles(for: shop))
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            SearchTextResultView(query: viewModel?.query ?? "")
            
            ErrorStateView(
                title: "نتیجه‌ای یافت نشد!"
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private var errorView: some View {
        ErrorStateView(
            title: "خطا در بارگذاری",
            message: "دوباره تلاش کنید."
        )
    }
}

#Preview {
    SearchView()
        .environment(\.homeService, HomeServiceImpl())
}
