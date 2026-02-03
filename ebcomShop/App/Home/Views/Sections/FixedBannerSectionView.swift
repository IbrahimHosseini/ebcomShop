//
//  FixedBannerSectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Kingfisher
import SwiftUI

struct FixedBannerSectionView: View {
    let title: String?
    let items: [BannerModel]

    private let horizontalPadding: CGFloat = 16
    private let spacing: CGFloat = 8
    private let ratio: CGFloat = 0.792

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = max(0, geometry.size.width - horizontalPadding * 2)
            let halfWidth = (availableWidth - spacing) / 2

            let sectionHeight: CGFloat = {
                switch items.count {
                case 1:
                    return availableWidth * ratio
                case 2:
                    return halfWidth * ratio
                case 3:
                    let smallHeight = halfWidth * ratio
                    return smallHeight * 2 + spacing
                default:
                    let rowHeight = halfWidth * ratio
                    return rowHeight * 2 + spacing
                }
            }()

            VStack(alignment: .leading, spacing: 12) {
                if let title, !title.isEmpty {
                    Text(title)
                        .typography(.caption)
                        .foregroundStyle(Color.black900)
                        .padding(.horizontal, horizontalPadding)
                }

                Group {
                    switch items.count {
                    case 1:
                        oneItemLayout(width: availableWidth)
                    case 2:
                        twoItemsLayout(halfWidth: halfWidth)
                    case 3:
                        threeItemsLayout(halfWidth: halfWidth)
                    case 4:
                        fourOrMoreItemsLayout(halfWidth: halfWidth)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: sectionHeight)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 8)
            }
            .padding(.vertical, 8)
            .frame(width: geometry.size.width, height: nil, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, minHeight: 390)
    }

    @ViewBuilder
    private func oneItemLayout(width: CGFloat) -> some View {
        FixedBannerImageView(imageUrl: items[0].imageUrl, width: width, height: width * ratio)
    }

    @ViewBuilder
    private func twoItemsLayout(halfWidth: CGFloat) -> some View {
        HStack(spacing: spacing) {
            FixedBannerImageView(imageUrl: items[0].imageUrl, width: halfWidth, height: halfWidth * ratio)
            FixedBannerImageView(imageUrl: items[1].imageUrl, width: halfWidth, height: halfWidth * ratio)
        }
    }

    @ViewBuilder
    private func threeItemsLayout(halfWidth: CGFloat) -> some View {
        let smallHeight = halfWidth * ratio
        let largeHeight = smallHeight * 2 + spacing
        HStack(alignment: .top, spacing: spacing) {
            FixedBannerImageView(imageUrl: items[0].imageUrl, width: halfWidth, height: largeHeight)
            VStack(spacing: spacing) {
                FixedBannerImageView(imageUrl: items[1].imageUrl, width: halfWidth, height: smallHeight)
                FixedBannerImageView(imageUrl: items[2].imageUrl, width: halfWidth, height: smallHeight)
            }
        }
    }

    /// 2×2 grid: full-width rows, two columns per row.
    @ViewBuilder
    private func fourOrMoreItemsLayout(halfWidth: CGFloat) -> some View {
        let rowHeight = halfWidth * ratio
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(Array(items.prefix(2).enumerated()), id: \.offset) { _, banner in
                    FixedBannerImageView(imageUrl: banner.imageUrl, width: halfWidth, height: rowHeight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: spacing) {
                ForEach(Array(items.dropFirst(2).prefix(2).enumerated()), id: \.offset) { _, banner in
                    FixedBannerImageView(imageUrl: banner.imageUrl, width: halfWidth, height: rowHeight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FixedBannerImageView: View {
    let imageUrl: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        KFImage(URL(string: imageUrl))
            .placeholder { ProgressView() }
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
    }
}


#Preview {
    FixedBannerSectionView(title: "برنامه یلدایی", items: [
//        BannerModel(id: "12", imageUrl: "http://185.204.197.213:5906/images/1.png"),
        BannerModel(id: "142", imageUrl: "http://185.204.197.213:5906/images/1.png"),
        BannerModel(id: "22", imageUrl: "http://185.204.197.213:5906/images/2.png"),
        BannerModel(id: "32", imageUrl: "http://185.204.197.213:5906/images/3.png"),
//        BannerModel(id: "33", imageUrl: "http://185.204.197.213:5906/images/2.png"),
//        BannerModel(id: "34", imageUrl: "http://185.204.197.213:5906/images/3.png"),
    ])
}
