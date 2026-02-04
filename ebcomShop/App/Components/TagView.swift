//
//  TagView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// A reusable tag/chip view with caption typography and pill style.
///
/// Usage:
/// ```swift
/// TagView(title: tagTitle)
/// ```
struct TagView: View {
    let title: String

    var body: some View {
        Text(title)
            .typography(.badge)
            .foregroundStyle(.gray500)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.grayDeactive)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}


#Preview {
    TagView(title: "فروشگاه")
}
