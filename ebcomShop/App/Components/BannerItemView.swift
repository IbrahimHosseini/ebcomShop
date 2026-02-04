//
//  BannerItemView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Kingfisher
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
        KFImage(URL(string: imageUrl))
            .onSuccess { result in
                let size = result.image.size
                guard size.width > 0 else { return }
                let ratio = size.height / size.width
                Task { @MainActor in
                    aspectRatio = ratio
                }
            }
            .placeholder { ProgressView() }
            .resizable()
            .scaledToFill()
            .frame(width: width, height: width * aspectRatio)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

