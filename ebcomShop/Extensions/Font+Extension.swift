import SwiftUI

// MARK: - Custom Font Names

/// IRANYekan font variants (from Resources/Fonts). Use .medium for semibold-style text.
enum CustomFont: String, CaseIterable {
    case regular = "IRANYekan"
    case medium = "IRANYekan-Medium"
    case bold = "IRANYekan-Bold"
}

// MARK: - Typography System

/// Typography styles based on Shop Design specifications
struct TypographyStyle {
    let font: Font
    let size: CGFloat
    let lineHeight: CGFloat

    static let display = TypographyStyle(
        font: Font.custom(.bold, size: 34),
        size: 34,
        lineHeight: 41
    )

    static let title = TypographyStyle(
        font: Font.custom(.medium, size: 28),
        size: 28,
        lineHeight: 34
    )

    static let title2 = TypographyStyle(
        font: Font.custom(.medium, size: 22),
        size: 22,
        lineHeight: 28
    )

    static let title3 = TypographyStyle(
        font: Font.custom(.medium, size: 20),
        size: 20,
        lineHeight: 25
    )

    static let headline = TypographyStyle(
        font: Font.custom(.medium, size: 17),
        size: 17,
        lineHeight: 22
    )

    static let body = TypographyStyle(
        font: Font.custom(.regular, size: 17),
        size: 17,
        lineHeight: 22
    )

    static let body24 = TypographyStyle(
        font: Font.custom(.regular, size: 24),
        size: 24,
        lineHeight: 29
    )

    static let callout = TypographyStyle(
        font: Font.custom(.medium, size: 16),
        size: 16,
        lineHeight: 21
    )

    static let footnote = TypographyStyle(
        font: Font.custom(.regular, size: 13),
        size: 13,
        lineHeight: 18
    )

    static let subheading = TypographyStyle(
        font: Font.custom(.medium, size: 15),
        size: 15,
        lineHeight: 20
    )

    static let caption = TypographyStyle(
        font: Font.custom(.medium, size: 12),
        size: 12,
        lineHeight: 16
    )

    static let caption2 = TypographyStyle(
        font: Font.custom(.medium, size: 11),
        size: 11,
        lineHeight: 14
    )

    static let primaryButton = TypographyStyle(
        font: Font.custom(.medium, size: 16),
        size: 16,
        lineHeight: 20
    )

    static let secondaryButton = TypographyStyle(
        font: Font.custom(.medium, size: 16),
        size: 16,
        lineHeight: 20
    )

    static let chip = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 20
    )

    static let chipSemibold = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 20
    )

    static let input = TypographyStyle(
        font: Font.custom(.regular, size: 16),
        size: 16,
        lineHeight: 21
    )

    static let hint = TypographyStyle(
        font: Font.custom(.medium, size: 13),
        size: 13,
        lineHeight: 18
    )

    static let message = TypographyStyle(
        font: Font.custom(.medium, size: 13),
        size: 13,
        lineHeight: 18
    )

    static let tabbar = TypographyStyle(
        font: Font.custom(.medium, size: 10),
        size: 10,
        lineHeight: 12
    )

    static let segmented = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 20
    )

    static let unSegmented = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 20
    )

    static let toast = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 20
    )
}

// MARK: - Font Extensions

extension Font {
    static func custom(_ font: CustomFont, size: CGFloat) -> Font {
        Font.custom(font.rawValue, size: size)
    }

    // Size-based helpers
    static func customRegular(_ size: CGFloat) -> Font { custom(.regular, size: size) }
    static func customMedium(_ size: CGFloat) -> Font { custom(.medium, size: size) }
    static func customBold(_ size: CGFloat) -> Font { custom(.bold, size: size) }

    // Typography styles (Shop Design)
    static var display: Font { TypographyStyle.display.font }
    static var title: Font { TypographyStyle.title.font }
    static var title2: Font { TypographyStyle.title2.font }
    static var title3: Font { TypographyStyle.title3.font }
    static var headline: Font { TypographyStyle.headline.font }
    static var body: Font { TypographyStyle.body.font }
    static var body24: Font { TypographyStyle.body24.font }
    static var callout: Font { TypographyStyle.callout.font }
    static var subheading: Font { TypographyStyle.subheading.font }
    static var footnote: Font { TypographyStyle.footnote.font }
    static var caption: Font { TypographyStyle.caption.font }
    static var caption2: Font { TypographyStyle.caption2.font }
    static var primaryButton: Font { TypographyStyle.primaryButton.font }
    static var secondaryButton: Font { TypographyStyle.secondaryButton.font }
    static var chip: Font { TypographyStyle.chip.font }
    static var chipSemibold: Font { TypographyStyle.chipSemibold.font }
    static var input: Font { TypographyStyle.input.font }
    static var hint: Font { TypographyStyle.hint.font }
    static var message: Font { TypographyStyle.message.font }
    static var tabbar: Font { TypographyStyle.tabbar.font }
    static var segmented: Font { TypographyStyle.segmented.font }
    static var unSegmented: Font { TypographyStyle.unSegmented.font }
    static var toast: Font { TypographyStyle.toast.font }
}

// MARK: - Typography Modifier

struct TypographyModifier: ViewModifier {
    let style: TypographyStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(max(0, style.lineHeight - style.size))
    }
}

// MARK: - View Extensions

extension View {
    /// Apply typography style (font + line spacing)
    func typography(_ style: TypographyStyle) -> some View {
        modifier(TypographyModifier(style: style))
    }
}
