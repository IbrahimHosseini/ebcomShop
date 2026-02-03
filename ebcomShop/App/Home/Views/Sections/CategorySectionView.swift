//
//  CategorySectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct CategorySectionView: View {
    let title: String?
    let items: [CategoryModel]

    private let horizontalPadding: CGFloat = 16
    private let itemSpacing: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                HStack {
                    Text(title)
                        .typography(.caption)
                        .foregroundStyle(Color.black900)
                        .padding(.horizontal, horizontalPadding)
                    
                    Spacer()
                    
                    Button("مشاهده همه") {
                        
                    }
                    .typography(.caption)
                    .foregroundStyle(Color.greenPrimery)
                    .padding(.horizontal, horizontalPadding)
                    
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(items) { category in
                        CategoryItemView(category: category)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CategorySectionView(
        title: "فروشگاه اینترنتی",
        items: [
            .init(
                id: "skdjhsk",
                title: "فروشگاه زنجیره‌ای",
                iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/shop/5f22c4b8-d38c-428e-adf2-41cc4f44ba5f.png",
                status: nil
            ),
            .init(
                id: "skdjhsk",
                title: "فروشگاه زنجیره‌ای",
                iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/shop/e76445d6-1153-43ed-85c2-986b8d6c5f76.png",
                status: nil
            ),
            .init(
                id: "skdjhsk",
                title: "سوپرمارکت",
                iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/shop/21f6357e-58c7-4240-98cc-e4f9344c59e5.png",
                status: nil
            ),
            .init(
                id: "skdjhsk",
                title: "آجیل و شیرینی",
                iconUrl: "https://static-ebcom.mci.ir/static/app/ewano/shop/03b82cda-996d-445c-9cdf-5e6bb8149d4e.png",
                status: nil
            )
        ]
    )
}
