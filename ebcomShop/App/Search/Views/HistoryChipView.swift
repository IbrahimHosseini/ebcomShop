//
//  HistoryChipView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// A tappable chip showing a search history term (icon + text in a capsule).
struct HistoryChipView: View {
    let term: String
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onTap) {
                Image(.resent)
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray500)
                Text(term)
                    .typography(.body)
                    .foregroundStyle(.gray500)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.background))
        .clipShape(Capsule())
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.grayDivider, lineWidth: 1)
        )
    }
}
