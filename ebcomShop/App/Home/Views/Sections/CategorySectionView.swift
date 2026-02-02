//
//  CategorySectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct CategorySectionView: View {
    let title: String?
    let items: [CategoryModel]

    private let horizontalPadding: CGFloat = 16
    private let itemSpacing: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                Text(title)
                    .typography(.title3)
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, horizontalPadding)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(items) { category in
                        CategoryItemView(category: category)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 8)
    }
}
