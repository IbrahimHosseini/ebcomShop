//
//  BannerSectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct BannerSectionView: View {
    let items: [BannerModel]

    private let horizontalPadding: CGFloat = 16
    @State private var aspectRatio: CGFloat = 0.5

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width - horizontalPadding * 2
            let height = width * aspectRatio
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { banner in
                        BannerItemView(
                            imageUrl: banner.imageUrl,
                            width: width,
                            aspectRatio: $aspectRatio
                        )
                        .frame(width: width, height: height)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 8)
            }
        }
        .frame(height: (UIScreen.main.bounds.width - horizontalPadding * 2) * aspectRatio + 16)
        .padding(.vertical, 8)
    }
}
