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
    let showsSearch: Bool
    /// Placeholder text shown inside the search affordance.
    let placeholder: String
    /// Called when the search affordance is tapped. Use this to navigate or present search.
    let onSearchTapped: (() -> Void)?

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
                Button {
                    onSearchTapped?()
                } label: {
                    HStack(spacing: 8) {
                        Image(.search)
                            .renderingMode(.template)
                            .foregroundStyle(.gray400)

                        Text(placeholder)
                            .typography(.callout)
                            .foregroundStyle(Color.gray400)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color.background)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray200, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
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
