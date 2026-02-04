//
//  SectionHeaderView.swift
//  ebcomShop
//
//  Created by Assistant on 2026-02-04.
//

import SwiftUI

/// A reusable header row with a leading title and a trailing action button (e.g., "مشاهده همه").
/// - Parameters:
///   - title: The leading title text.
///   - actionTitle: The trailing button title. Defaults to "مشاهده همه".
///   - horizontalPadding: Horizontal padding applied to the title and action, defaults to 16.
///   - action: Closure invoked when the trailing button is tapped.
struct SectionHeaderView: View {
    let title: String
    let actionTitle: String
    let horizontalPadding: CGFloat
    let action: () -> Void

    init(
        title: String,
        actionTitle: String = "مشاهده همه",
        horizontalPadding: CGFloat = 16,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.horizontalPadding = horizontalPadding
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .typography(.caption)
                .foregroundStyle(Color.black900)
                .padding(.horizontal, horizontalPadding)

            Spacer()

            Button(actionTitle) {
                action()
            }
            .typography(.caption)
            .foregroundStyle(Color.greenPrimery)
            .padding(.horizontal, horizontalPadding)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SectionHeaderView(title: "عنوان بخش") { }
        SectionHeaderView(title: "عنوان بخش", actionTitle: "سفارشی", horizontalPadding: 24) { }
    }
    .padding()
}