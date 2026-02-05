//
//  SearchBarView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// A reusable search bar: either an editable TextField with clear button or a tappable placeholder.
///
/// Usage:
/// ```swift
/// // Editable (e.g. search screen)
/// SearchBarView(placeholder: "جستجو...", text: $query)
///
/// // Tappable placeholder (e.g. header)
/// SearchBarView.placeholderOnly(placeholder: "جستجو...", onTap: { showSearch = true })
/// ```
struct SearchBarView: View {
    let placeholder: String
    @Binding var text: String
    var borderColor: Color = .greenPrimery
    var onClear: (() -> Void)? = nil

    /// Editable search bar with optional clear action.
    init(
        placeholder: String = "جستجو فروشگاه یا برند...",
        text: Binding<String>,
        borderColor: Color = .greenPrimery,
        onClear: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.borderColor = borderColor
        self.onClear = onClear
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(.search)
                .renderingMode(.template)
                .foregroundStyle(.gray400)

            TextField(placeholder, text: $text)
                .typography(.body)
                .foregroundStyle(.primary)
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    if let onClear {
                        onClear()
                    } else {
                        text = ""
                    }
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
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Placeholder-only (button) variant

extension SearchBarView {
    /// Tappable search bar that shows placeholder only (e.g. in header to open search).
    static func placeholderOnly(
        placeholder: String = "جستجو فروشگاه یا برند...",
        borderColor: Color = Color.inputBorder,
        onTap: @escaping () -> Void
    ) -> SearchBarPlaceholderView {
        SearchBarPlaceholderView(placeholder: placeholder, borderColor: borderColor, onTap: onTap)
    }
}

struct SearchBarPlaceholderView: View {
    let placeholder: String
    let borderColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(.search)
                    .renderingMode(.template)
                    .foregroundStyle(.gray400)

                Text(placeholder)
                    .typography(.body)
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
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
