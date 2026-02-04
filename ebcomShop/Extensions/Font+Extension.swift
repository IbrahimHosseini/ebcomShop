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

    static let title = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 18
    )
    
    static let badge = TypographyStyle(
        font: Font.custom(.medium, size: 9),
        size: 9,
        lineHeight: 12
    )
    
    static let subtitle = TypographyStyle(
        font: Font.custom(.bold, size: 12),
        size: 12,
        lineHeight: 16
    )
    
    static let primaryButton = TypographyStyle(
        font: Font.custom(.medium, size: 16),
        size: 16,
        lineHeight: 20
    )
    
    static let secondaryButton = TypographyStyle(
        font: Font.custom(.medium, size: 12),
        size: 12,
        lineHeight: 20
    )
    
    static let body = TypographyStyle(
        font: Font.custom(.regular, size: 12),
        size: 12,
        lineHeight: 16
    )
    
    
    
    static let headline = TypographyStyle(
        font: Font.custom(.medium, size: 17),
        size: 17,
        lineHeight: 22
    )

    static let callout = TypographyStyle(
        font: Font.custom(.medium, size: 16),
        size: 16,
        lineHeight: 21
    )

    static let footnote = TypographyStyle(
        font: Font.custom(.regular, size: 13),
        size: 12,
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
    



    static let chip = TypographyStyle(
        font: Font.custom(.medium, size: 14),
        size: 14,
        lineHeight: 20
    )

    static let chipSemibold = TypographyStyle(
        font: Font.custom(.medium, size: 12),
        size: 12,
        lineHeight: 20
    )

    static let input = TypographyStyle(
        font: Font.custom(.regular, size: 16),
        size: 16,
        lineHeight: 21
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
    static var headline: Font { TypographyStyle.headline.font }
    static var callout: Font { TypographyStyle.callout.font }
    static var subheading: Font { TypographyStyle.subheading.font }
    static var footnote: Font { TypographyStyle.footnote.font }
    static var caption: Font { TypographyStyle.caption.font }
    static var caption2: Font { TypographyStyle.caption2.font }
    static var primaryButton: Font { TypographyStyle.primaryButton.font }
    static var chip: Font { TypographyStyle.chip.font }
    static var chipSemibold: Font { TypographyStyle.chipSemibold.font }
    static var input: Font { TypographyStyle.input.font }
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
