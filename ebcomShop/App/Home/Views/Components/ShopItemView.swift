//
//  ShopItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Kingfisher
import SwiftUI

struct ShopItemView: View {
    let shop: ShopModel

    var body: some View {
        VStack(spacing: 6) {
            KFImage(URL(string: shop.iconUrl))
                .placeholder { ProgressView() }
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(shop.title)
                .typography(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}
