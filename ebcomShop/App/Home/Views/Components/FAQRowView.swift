//
//  FAQRowView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

struct FAQRowView: View {
    let title: String
    let description: String
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(title)
                        .typography(.footnote)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.black900)
                    Spacer()
                    Image(isExpanded ? .arrowUp : .arrowDown)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(description)
                    .typography(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .background(Color.background)
    }
}
