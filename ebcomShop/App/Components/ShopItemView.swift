//
//  ShopItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct ShopItemView: View {
    private let shop: ShopModel
    private let logoRatio: CGFloat = 0.7
    
    init(shop: ShopModel) {
        self.shop = shop
    }

    var body: some View {

        VStack(alignment: .center) {
            
            GeometryReader { geo in
                let width = geo.size.width
                let logoSize = floor(width * logoRatio)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.grayDeactive)
                        .stroke(.grayDivider, lineWidth: 1)
                        

                    AppImageView(
                        url: shop.iconUrl,
                        width: logoSize,
                        height: logoSize,
                        cornerRadius: 0
                    )
                }
                .frame(width: width, height: width)
                .frame(maxWidth: .infinity)
                
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(shop.title)
                .typography(.subtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray500)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        
    }
}

#Preview {
    ShopItemView(
        shop: ShopModel(
        id: "1",
        title: "دیجی کالا",
        iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/clients/fcf12143-adf5-4790-bbe3-63932b45de16.png",
        labels: nil,
        tags: nil,
        categories: nil,
        about: nil,
        type: nil,
        code: nil,
        status: nil
        )
    )
}
