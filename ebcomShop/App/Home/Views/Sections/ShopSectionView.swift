//
//  ShopSectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct ShopSectionView: View {
    let title: String?
    let items: [ShopModel]

    private let horizontalPadding: CGFloat = 16
    private let columns = 4
    private let spacing: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                Text(title)
                    .typography(.title3)
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, horizontalPadding)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(items) { shop in
                    ShopItemView(shop: shop)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
        }
        .padding(.vertical, 8)
    }
}
