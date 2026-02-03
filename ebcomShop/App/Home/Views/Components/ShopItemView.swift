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
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.categoryBackground)
                        .stroke(Color.categoryBorder, style: .init(lineWidth: 1))
                )
                

            Text(shop.title)
                .typography(.chipSemibold)
                .foregroundStyle(Color.gray500)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ShopItemView(shop: ShopModel(
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
    ))
}
