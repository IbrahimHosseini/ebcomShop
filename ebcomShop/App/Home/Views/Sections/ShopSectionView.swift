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
    private let count = 4
    private let row = 3
    private let columnSpacing: CGFloat = 12
    private let rowSpacing: CGFloat = 32
    
    var body: some View {
        
        let columns = Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: count)
        
        let maxItems = count * row
        
        VStack {
            
            if let title, !title.isEmpty {
                SectionHeaderView(title: title) {
                    // TODO: navigate to list view
                }
            }
            
            LazyVGrid(columns: columns, spacing: rowSpacing) {
                ForEach(items.prefix(maxItems)) { item in
                    ShopItemView(shop: item)
                }
            }
            .padding(.horizontal, horizontalPadding)
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
        title: "فروشگاه آنلاین",
        items: [
            ShopModel(
            id: "1",
            title: "دیجی کالا",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "2",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "3",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "4",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "5",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "6",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "7",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "17",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "71",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "73",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "8",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "9",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "10",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
            ShopModel(
            id: "11",
            title: "دیجی کالا مارکت",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil),
        ]
    )
}
