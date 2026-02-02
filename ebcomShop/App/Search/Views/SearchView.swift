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
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SearchViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task { viewModel = SearchViewModel(homeService: homeService) }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(.back)
                    }
                    .buttonStyle(.plain)
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(.back)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("جستجو")
                    .font(.customMedium(12))
                    .foregroundStyle(Color.gray300)
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: SearchViewModel) -> some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            searchBar(viewModel: viewModel)
            if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                historySection(viewModel: viewModel)
            }
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
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
        HStack(spacing: 8) {
            Image(.search)
                .renderingMode(.template)
                .foregroundStyle(.gray400)

            TextField("جستجو فروشگاه یا برند...", text: $viewModel.query)
                .typography(.input)
                .foregroundStyle(.primary)
                .submitLabel(.search)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.clearQuery()
                } label: {
                    Image(.closeCircle)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.gray200, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func historySection(@Bindable viewModel: SearchViewModel) -> some View {
        if !viewModel.history.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.history, id: \.self) { term in
                        historyChip(term: term, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
        }
    }

    private func historyChip(term: String, viewModel: SearchViewModel) -> some View {
        HStack(spacing: 6) {
            Button {
                viewModel.applyHistory(term)
            } label: {
                Text(term)
                    .typography(.chip)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)

            Button {
                viewModel.deleteHistory(term)
            } label: {
                Image(.delete)
                    .typography(.caption2)
                    .foregroundStyle(.gray400)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray200, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func resultsList(@Bindable viewModel: SearchViewModel) -> some View {
        if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 {
            ForEach(viewModel.results) { shop in
                SearchResultRow(shop: shop)
                Divider()
                    .padding(.leading, 76)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Text("نتیجه‌ای یافت نشد")
                .typography(.headline)
            Text("نتیجه‌ای برای جستجوی شما پیدا نکردیم.")
                .typography(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var errorView: some View {
        VStack(spacing: 8) {
            Text("خطا در بارگذاری")
                .typography(.headline)
            Text("دوباره تلاش کنید.")
                .typography(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

private struct SearchResultRow: View {
    let shop: ShopModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: shop.iconUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    Color(.systemGray5)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(shop.title)
                    .typography(.subheading)
                    .foregroundStyle(.primary)

                if let tags = shop.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .typography(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SearchView()
        .environment(\.homeService, HomeServiceImpl())
}
