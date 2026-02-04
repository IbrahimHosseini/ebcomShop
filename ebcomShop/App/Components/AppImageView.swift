//
//  AppImageView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import Kingfisher
import SwiftUI

/// A reusable remote image view with placeholder, fade, and optional size/clipping.
///
/// Usage:
/// ```swift
/// AppImageView(url: shop.iconUrl, width: 24, height: 24, cornerRadius: 10)
/// AppImageView(url: imageUrl, width: w, height: h, contentMode: .fill)
/// ```
struct AppImageView: View {
    let url: String
    var width: CGFloat?
    var height: CGFloat?
    var cornerRadius: CGFloat? = 10
    var contentMode: ContentMode = .fit
    var fadeDuration: Double = 0.25

    @ViewBuilder
    var body: some View {
        let image = KFImage(URL(string: url))
            .placeholder { AppProgressView() }
            .fade(duration: fadeDuration)
            .resizable()

        Group {
            switch contentMode {
            case .fit:
                image.scaledToFit()
            case .fill:
                image.scaledToFill().clipped()
            }
        }
        .frame(width: width, height: height)
        .modifier(OptionalClipShapeModifier(cornerRadius: cornerRadius))
    }
}

private struct OptionalClipShapeModifier: ViewModifier {
    let cornerRadius: CGFloat?

    func body(content: Content) -> some View {
        if let radius = cornerRadius {
            content.clipShape(RoundedRectangle(cornerRadius: radius))
        } else {
            content
        }
    }
}
