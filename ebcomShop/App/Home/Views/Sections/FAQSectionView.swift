//
//  FAQSectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct FAQSectionView: View {
    let faq: FAQPayload
    @State private var expandedIndex: Int?

    private let horizontalPadding: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(faq.title)
                .typography(.title3)
                .foregroundStyle(Color(.label))
                .padding(.horizontal, horizontalPadding)

            VStack(spacing: 8) {
                ForEach(Array(faq.sections.enumerated()), id: \.offset) { index, section in
                    FAQRowView(
                        title: section.title,
                        description: section.description,
                        isExpanded: expandedIndex == index,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedIndex = expandedIndex == index ? nil : index
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.vertical, 16)
    }
}
