//
//  SearchView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Kingfisher
import Observation
import SwiftUI

struct SearchView: View {
    @Environment(\.homeService) private var homeService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SearchViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        viewModel = SearchViewModel(
                            homeService: homeService,
                            searchHistoryRepository: SearchHistoryRepository(modelContext: modelContext)
                        )
                    }
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
                .stroke(.greenPrimery, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func historySection(@Bindable viewModel: SearchViewModel) -> some View {
        if !viewModel.history.isEmpty {
            
            HStack {
                Text("جستجو های اخیر")
                    .typography(.headline)
                
                Spacer()
                
                Button {
                    viewModel.deleteHistory(viewModel.history)
                } label: {
                    Image(.delete)
                        .typography(.caption2)
                        .foregroundStyle(.gray400)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(viewModel.history, id: \.self) { term in
                    historyChip(term: term, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func historyChip(term: String, viewModel: SearchViewModel) -> some View {
        HStack(spacing: 6) {
            Button {
                viewModel.applyHistory(term)
            } label: {
                Image(.resent)
                Text(term)
                    .typography(.chip)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.background))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray50, lineWidth: 1)
        )
    }

    /// Vertical list of found shops (logo, title, tags). Data comes from local filter on fetched shops only.
    @ViewBuilder
    private func resultsList(@Bindable viewModel: SearchViewModel) -> some View {
        if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 {
            
            searchTextTitle
            
            ForEach(viewModel.results) { shop in
                SearchResultRow(shop: shop, tagTitles: viewModel.tagTitles(for: shop))
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            searchTextTitle
            
            Spacer()
            Text("نتیجه‌ای یافت نشد!")
                .typography(.headline)
                .padding(.top, 48)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var searchTextTitle: some View {
        HStack(spacing: 8) {
            Image(.search2)
            Text("جستجو برای '\(viewModel?.query ?? "")' ")
                .typography(.headline)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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

/// Single row in search results: logo, title, and tag titles (vertical list item).
private struct SearchResultRow: View {
    let shop: ShopModel
    let tagTitles: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                
                KFImage(URL(string: shop.iconUrl))
                    .placeholder { ProgressView() }
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(shop.title)
                    .typography(.subheading)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(.openArrow)
            }
                

            if !tagTitles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tagTitles, id: \.self) { tagTitle in
                            Text(tagTitle)
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
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Flow Layout (wraps to next row when row is full)

private struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + verticalSpacing
                totalHeight = y + size.height
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
            totalHeight = max(totalHeight, y + rowHeight)
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

#Preview {
    SearchView()
        .environment(\.homeService, HomeServiceImpl())
}
