//
//  CategoryItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct CategoryItemView: View {
    private let category: CategoryModel
    private let itemWidth: CGFloat
    private let iconSize: CGFloat
    
    init(itemWidth: CGFloat, category: CategoryModel) {
        self.category = category
        self.itemWidth = itemWidth
        self.iconSize = itemWidth * 0.6
    }

    var body: some View {
        VStack(spacing: 8) {
            AppImageView(
                url: category.iconUrl,
                width: iconSize,
                height: iconSize,
                cornerRadius: 0
            )
            .padding(16)
            .background(
                Circle()
                    .fill(Color.categoryBackground)
                    .stroke(Color.categoryBorder, style: .init(lineWidth: 1))
            )

            Text(category.title)
                .typography(.subtitle)
                .foregroundStyle(Color.grayBold)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(width: itemWidth)
        }
        .frame(width: itemWidth)
    }
}

#Preview {
    CategoryItemView(
        itemWidth: 72,
        category: .init(
            id: "1",
            title: "فروشگاه زنجیره‌ای",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/shop/21f6357e-58c7-4240-98cc-e4f9344c59e5.png",
            status: nil
        )
    )
}
