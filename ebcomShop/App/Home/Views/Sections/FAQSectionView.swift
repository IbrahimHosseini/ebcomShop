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
            
            SectionHeaderView(title: faq.title)

            VStack(spacing: 0) {
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
                    
                    if index < faq.sections.count - 1 {
                        Divider()
                            .foregroundStyle(Color.gray50)
                            .padding(.horizontal, horizontalPadding)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color.background)
    }
}


#Preview {
    FAQSectionView(
        faq: FAQPayload(
            id: "1",
            title: "سوال برات پیش می‌آید",
            sections: [
                FAQSectionItem(title: "سوال ۱", description: "چواب ۱"),
                FAQSectionItem(title: "سوال ۲", description: "چواب ۲"),
                FAQSectionItem(title: "سوال ۳", description: "چواب ۳"),
                FAQSectionItem(title: "سوال ۴", description: "چواب ۴"),
                FAQSectionItem(title: "سوال ۵", description: "چواب ۵"),
                FAQSectionItem(title: "سوال ۶", description: "چواب ۶"),
            ]
        )
    )
}
