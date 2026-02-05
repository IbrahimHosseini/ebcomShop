//
//  SearchTextResultView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// Header row showing the current search query (e.g. above empty state or results).
struct SearchTextResultView: View {
    let query: String

    var body: some View {
        HStack(spacing: 8) {
            Image(.search2)
                .renderingMode(.template)
                .foregroundStyle(Color.grayBold)

            Text("جستجو برای \"\(query)\" ")
                .typography(.subtitle)
                .foregroundStyle(Color.grayBold)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}
