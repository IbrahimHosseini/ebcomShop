//
//  ShopItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct ShopItemView: View {
    private let shop: ShopModel
    private let itemWidth: CGFloat
    private let containerSizeRatio: CGFloat = 1.3
    
    init(shop: ShopModel, itemWidth: CGFloat) {
        self.shop = shop
        self.itemWidth = itemWidth
    }

    var body: some View {
        let resolvedWidth = itemWidth > 0 ? itemWidth : 56
        let logoSizeRatio: CGFloat = containerSizeRatio * 0.7
        
        let containerSize = max(0, floor(resolvedWidth * containerSizeRatio))
        let logoSize = max(0, floor(resolvedWidth * logoSizeRatio))

        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.grayDeactive)
                    .stroke(.gray50, lineWidth: 1)
                    

                AppImageView(url: shop.iconUrl, width: logoSize, height: logoSize, cornerRadius: 0)
            }
            .frame(width: containerSize, height: containerSize)


            Text(shop.title)
                .typography(.chipSemibold)
                .foregroundStyle(Color.gray500)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ShopItemView(
        shop: ShopModel(
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
        ),
        itemWidth: 80
    )
}
