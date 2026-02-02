import SwiftUI

enum CustomFont: String {
    case regular = "IRANYekan"
    case medium = "IRANYekan-Medium"
    case bold = "IRANYekan-Bold"
}

extension Font {
    static func custom(_ font: CustomFont, size: CGFloat) -> Font {
        Font.custom(font.rawValue, size: size)
    }

    static func regular(_ size: CGFloat) -> Font {
        custom(.regular, size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        custom(.medium, size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        custom(.bold, size: size)
    }
}
