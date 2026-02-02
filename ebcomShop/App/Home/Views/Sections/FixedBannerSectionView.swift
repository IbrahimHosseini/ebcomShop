//
//  FixedBannerSectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct FixedBannerSectionView: View {
    let title: String?
    let items: [BannerModel]

    private let horizontalPadding: CGFloat = 16
    private let spacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                Text(title)
                    .typography(.title3)
                    .foregroundStyle(Color(.label))
                    .padding(.horizontal, horizontalPadding)
            }

            let width = UIScreen.main.bounds.width - horizontalPadding * 2
            let halfWidth = (width - spacing) / 2
            let quarterWidth = (width - spacing * 3) / 4
            let ratio: CGFloat = 0.5
            let sectionHeight: CGFloat = {
                switch items.count {
                case 1: return width * ratio
                case 2: return halfWidth * ratio
                case 3: let h = halfWidth * ratio; return h * 2 + spacing
                default: return (quarterWidth * ratio) * 2 + spacing
                }
            }()

            Group {
                switch items.count {
                case 1:
                    oneItemLayout(width: width)
                case 2:
                    twoItemsLayout(halfWidth: halfWidth, width: width)
                case 3:
                    threeItemsLayout(halfWidth: halfWidth, width: width)
                case 4...:
                    fourOrMoreItemsLayout(quarterWidth: quarterWidth, width: width)
                default:
                    EmptyView()
                }
            }
            .frame(height: sectionHeight)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func oneItemLayout(width: CGFloat) -> some View {
        let ratio: CGFloat = 0.5
        FixedBannerImageView(imageUrl: items[0].imageUrl, width: width, height: width * ratio)
    }

    @ViewBuilder
    private func twoItemsLayout(halfWidth: CGFloat, width: CGFloat) -> some View {
        let ratio: CGFloat = 0.5
        HStack(spacing: spacing) {
            FixedBannerImageView(imageUrl: items[0].imageUrl, width: halfWidth, height: halfWidth * ratio)
            FixedBannerImageView(imageUrl: items[1].imageUrl, width: halfWidth, height: halfWidth * ratio)
        }
    }

    @ViewBuilder
    private func threeItemsLayout(halfWidth: CGFloat, width: CGFloat) -> some View {
        let ratio: CGFloat = 0.5
        let leftHeight = halfWidth * ratio
        let rightHeight = leftHeight * 2 + spacing
        HStack(spacing: spacing) {
            VStack(spacing: spacing) {
                FixedBannerImageView(imageUrl: items[1].imageUrl, width: halfWidth, height: leftHeight)
                FixedBannerImageView(imageUrl: items[2].imageUrl, width: halfWidth, height: leftHeight)
            }
            FixedBannerImageView(imageUrl: items[0].imageUrl, width: halfWidth, height: rightHeight)
        }
    }

    @ViewBuilder
    private func fourOrMoreItemsLayout(quarterWidth: CGFloat, width: CGFloat) -> some View {
        let ratio: CGFloat = 0.5
        let rowHeight = quarterWidth * ratio
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(Array(items.prefix(2).enumerated()), id: \.offset) { _, banner in
                    FixedBannerImageView(imageUrl: banner.imageUrl, width: quarterWidth, height: rowHeight)
                }
            }
            HStack(spacing: spacing) {
                ForEach(Array(items.dropFirst(2).prefix(2).enumerated()), id: \.offset) { _, banner in
                    FixedBannerImageView(imageUrl: banner.imageUrl, width: quarterWidth, height: rowHeight)
                }
            }
        }
    }
}

private struct FixedBannerImageView: View {
    let imageUrl: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        BannerItemView(imageUrl: imageUrl, width: width)
            .frame(width: width, height: height)
    }
}
