//
//  CategoryItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct CategoryItemView: View {
    let category: CategoryModel

    private let itemWidth: CGFloat = 72
    private let iconSize: CGFloat = 50

    var body: some View {
        VStack(spacing: 8) {
            AppImageView(
                url: category.iconUrl,
                width: iconSize,
                height: iconSize,
                cornerRadius: 0
            )
            .padding(10)
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
        category: .init(
            id: "",
            title: "فروشگاه زنجیره‌ای",
            iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/shop/21f6357e-58c7-4240-98cc-e4f9344c59e5.png",
            status: nil
        )
    )
}
