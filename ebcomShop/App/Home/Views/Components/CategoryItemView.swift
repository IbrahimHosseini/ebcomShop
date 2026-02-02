//
//  CategoryItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Kingfisher
import SwiftUI

struct CategoryItemView: View {
    let category: CategoryModel

    private let itemWidth: CGFloat = 80
    private let iconSize: CGFloat = 56

    var body: some View {
        VStack(spacing: 8) {
            KFImage(URL(string: category.iconUrl))
                .placeholder { ProgressView() }
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(category.title)
                .typography(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(width: itemWidth)
        }
        .frame(width: itemWidth)
    }
}
