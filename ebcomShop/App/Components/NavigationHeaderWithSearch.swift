//
//  NavigationHeaderWithSearch.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

/// A reusable header that shows the app logo and an optional search affordance.
///
/// Usage examples:
/// ```swift
/// // 1) Logo only
/// NavigationHeaderWithSearch()
///
/// // 2) Logo + tappable search affordance
/// @State private var showSearch = false
///
/// NavigationHeaderWithSearch(showsSearch: true) {
///     showSearch = true
/// }
/// .background(
///     NavigationLink(destination: SearchView(), isActive: $showSearch) {
///         EmptyView()
///     }
///     .hidden()
/// )
/// ```
struct NavigationHeaderWithSearch: View {
    /// Whether to show the search affordance under the logo.
    private let showsSearch: Bool
    /// Placeholder text shown inside the search affordance.
    private let placeholder: String
    /// Called when the search affordance is tapped. Use this to navigate or present search.
    private let onSearchTapped: (() -> Void)?

    init(
        showsSearch: Bool = false,
        placeholder: String = "جستجو فروشگاه یا برند...",
        onSearchTapped: (() -> Void)? = nil
    ) {
        self.showsSearch = showsSearch
        self.placeholder = placeholder
        self.onSearchTapped = onSearchTapped
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 16)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                Spacer()
            }

            if showsSearch {
                SearchBarView.placeholderOnly(placeholder: placeholder, onTap: { onSearchTapped?() })
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background(Color.background)
    }
}

#Preview("Header with search") {
    VStack(spacing: 0) {
        NavigationHeaderWithSearch(showsSearch: true) {}
        Spacer()
    }
    .background(Color.background)
}

#Preview("Header without search") {
    VStack(spacing: 0) {
        NavigationHeaderWithSearch()
        Spacer()
    }
    .background(Color.background)
}
