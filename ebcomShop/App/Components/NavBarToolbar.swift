//
//  NavBarToolbar.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// A reusable inline nav bar with optional back button and title.
///
/// Usage:
/// ```swift
/// .navBarToolbar(title: "جستجو")
/// .navBarToolbar(title: "جستجو", showsBackButton: false)
/// .navBarToolbar(title: "Title", onBack: { customAction() })
/// ```
struct NavBarToolbarModifier: ViewModifier {
    let title: String
    var showsBackButton: Bool = true
    var onBack: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(showsBackButton)
            .toolbar {
                if showsBackButton {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarLeading) {
                            backButtonContent
                        }
                        .sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .topBarLeading) {
                            backButtonContent
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(title)
                        .typography(.title)
                        .foregroundStyle(Color.grayMedium)
                }
            }
    }

    @ViewBuilder
    private var backButtonContent: some View {
        Button {
            if let onBack {
                onBack()
            } else {
                dismiss()
            }
        } label: {
            Image(.back)
                .renderingMode(.template)
                .foregroundStyle(Color.grayBold)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func navBarToolbar(
        title: String,
        showsBackButton: Bool = true,
        onBack: (() -> Void)? = nil
    ) -> some View {
        modifier(NavBarToolbarModifier(title: title, showsBackButton: showsBackButton, onBack: onBack))
    }
}
