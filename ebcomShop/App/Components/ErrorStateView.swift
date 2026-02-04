//
//  ErrorStateView.swift
//  ebcomShop
//
//  Created by Assistant on 2026-02-04.
//

import SwiftUI

/// A reusable error state view with an optional retry button.
///
/// Usage:
/// ```swift
/// ErrorStateView(
///     title: "خطا در بارگذاری",
///     message: error?.localizedDescription,
///     onRetry: { await viewModel.load() }
/// )
/// ```
struct ErrorStateView: View {
    let title: String
    let message: String?
    let retryTitle: String
    let onRetry: (() async -> Void)?

    init(
        title: String = "خطا در بارگذاری",
        message: String? = nil,
        retryTitle: String = "تلاش مجدد",
        onRetry: (() async -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(title)
                .typography(.headline)

            if let message, !message.isEmpty {
                Text(message)
                    .typography(.footnote)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            if let onRetry {
                Button(retryTitle) {
                    Task { await onRetry() }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .typography(.primaryButton)
                .foregroundColor(.greenPrimery)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    Group {
        ErrorStateView(
            title: "خطا در بارگذاری",
            message: "لطفاً اتصال اینترنت خود را بررسی کنید."
        )
        ErrorStateView(
            title: "مشکلی پیش آمد",
            message: "نتوانستیم داده‌ها را بارگذاری کنیم.",
            onRetry: { }
        )
    }
}