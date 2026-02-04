//
//  AppProgressView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// A reusable loading indicator with full-screen, inline, or compact styles.
///
/// Usage:
/// ```swift
/// AppProgressView(style: .fullScreen)           // Initial screen load
/// AppProgressView(style: .inline(verticalPadding: 40))  // List loading
/// AppProgressView()                            // Image placeholder (compact)
/// ```
struct AppProgressView: View {
    enum Style {
        case fullScreen
        case inline(verticalPadding: CGFloat)
        case compact
    }

    private let style: Style

    init(style: Style = .compact) {
        self.style = style
    }

    var body: some View {
        Group {
            switch style {
            case .fullScreen:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .inline(let verticalPadding):
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, verticalPadding)
            case .compact:
                ProgressView()
            }
        }
    }
}
