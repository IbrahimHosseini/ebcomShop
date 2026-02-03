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
    @State private var selectedIndex: Int = 0

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width - horizontalPadding * 2
            let height = width * aspectRatio
            VStack(spacing: 8) {
                TabView(selection: $selectedIndex) {
                    ForEach(items.indices, id: \.self) { index in
                        let banner = items[index]
                        BannerItemView(
                            imageUrl: banner.imageUrl,
                            width: width,
                            aspectRatio: $aspectRatio
                        )
                        .frame(width: width, height: height)
                        .tag(index)
                    }
                }
                .frame(height: height)
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 4) {
                    ForEach(items.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(index == selectedIndex ? Color.greenPrimery : Color.gray100)
                            .frame(width: index == selectedIndex ? 12 : 6, height: 6)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedIndex)
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
        }
        .frame(height: (UIScreen.main.bounds.width - horizontalPadding * 2) * aspectRatio + 28)
        .padding(.vertical, 8)
    }
}


#Preview {
    BannerSectionView(
        items: [
            BannerModel(id: "1", imageUrl: "https://static-ebcom.mci.ir/static/app/ewano/banners/67c1554e-6c81-4e90-a0ca-42af504a9356.jpg"),
            BannerModel(id: "2", imageUrl: "https://static-ebcom.mci.ir/static/app/ewano/banners/7481dbef-15a4-4fe3-a0e3-735c24f78dc4.jpg"),
            BannerModel(id: "3", imageUrl: "https://static-ebcom.mci.ir/static/app/ewano/banners/7f47ef1a-51a7-4146-92e4-bad53ad1eacd.jpg"),
            BannerModel(id: "4", imageUrl: "https://static-ebcom.mci.ir/static/app/ewano/banners/22f6caee-40a7-4b2d-88df-f46b041319d3.jpg"),
        ]
    )
}

