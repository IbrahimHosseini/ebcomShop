//
//  SearchResultRowView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// Single row in search results: logo, title, and tag titles (vertical list item).
struct SearchResultRowView: View {
    let shop: ShopModel
    let tagTitles: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AppImageView(url: shop.iconUrl, width: 24, height: 24, cornerRadius: 10)

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
                            TagView(title: tagTitle)
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
