//
//  BannerItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct BannerItemView: View {
    let imageUrl: String
    let width: CGFloat
    @Binding var aspectRatio: CGFloat

    init(imageUrl: String, width: CGFloat, aspectRatio: Binding<CGFloat>? = nil) {
        self.imageUrl = imageUrl
        self.width = width
        self._aspectRatio = aspectRatio ?? Binding.constant(0.5)
    }

    var body: some View {
        AppImageView(
            url: imageUrl,
            width: width,
            height: width * aspectRatio,
            cornerRadius: 12,
            contentMode: .fill,
            onImageLoaded: { size in
                guard size.width > 0 else { return }
                
                let ratio = size.height / size.width
                
                Task { @MainActor in
                    aspectRatio = ratio
                }
            }
        )
    }
}

