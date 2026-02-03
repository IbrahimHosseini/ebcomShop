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
    private let rows = 3
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        let itemWidth = max(0, floor((availableWidth - (horizontalPadding * 2) - (spacing * CGFloat(columns - 1))) / CGFloat(columns)))

        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                HStack {
                    Text(title)
                        .typography(.caption)
                        .foregroundStyle(Color.black900)
                        .padding(.horizontal, horizontalPadding)
                    
                    Spacer()
                    
                    Button("مشاهده همه") {
                        // TODO: navigate to list view
                    }
                    .typography(.caption)
                    .foregroundStyle(Color.greenPrimery)
                    .padding(.horizontal, horizontalPadding)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(items.prefix(rows * columns)) { shop in
                    ShopItemView(shop: shop, itemWidth: itemWidth)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
        }
        .padding(.vertical, 8)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ShopSectionWidthKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(ShopSectionWidthKey.self) { width in
            if width != availableWidth {
                availableWidth = width
            }
        }
    }
}

private struct ShopSectionWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ShopSectionView(
        title: "Title",
        items: [ShopModel(
            id: "",
            title: "دیجی کالا",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )]
    )
}
