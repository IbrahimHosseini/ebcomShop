import SwiftUI

/// A reusable wrapper around `ToolbarItem` that standardizes how you add buttons to a toolbar.
///
/// Usage:
/// ```swift
/// .toolbar {
///     ReusableToolbarItem(placement: .navigationBarTrailing, systemImage: "plus") {
///         addItem()
///     }
///     ReusableToolbarItem(placement: .navigationBarLeading, title: "Edit", role: .destructive) {
///         deleteAll()
///     }
/// }
/// ```
public struct ReusableToolbarItem<Label: View>: View {
    private let placement: ToolbarItemPlacement
    private let action: () -> Void
    private let label: () -> Label
    private let role: ButtonRole?
    private let isDisabled: Bool

    /// Designated initializer allowing custom label content.
    /// - Parameters:
    ///   - placement: Where the toolbar item should appear.
    ///   - role: Optional button role (e.g. `.destructive`).
    ///   - disabled: Whether the button is disabled.
    ///   - action: Action invoked when the button is tapped.
    ///   - label: Custom label view for the button.
    public init(
        placement: ToolbarItemPlacement,
        role: ButtonRole? = nil,
        disabled: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.placement = placement
        self.role = role
        self.isDisabled = disabled
        self.action = action
        self.label = label
    }

    /// Convenience initializer for a system image label.
    /// - Parameters:
    ///   - placement: Where the toolbar item should appear.
    ///   - systemImage: SF Symbol name.
    ///   - role: Optional button role.
    ///   - disabled: Whether the button is disabled.
    ///   - action: Action invoked when the button is tapped.
    public init(
        placement: ToolbarItemPlacement,
        systemImage: String,
        role: ButtonRole? = nil,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) where Label == Image {
        self.init(placement: placement, role: role, disabled: disabled, action: action) {
            Image(systemName: systemImage)
        }
    }

    /// Convenience initializer for a text label.
    /// - Parameters:
    ///   - placement: Where the toolbar item should appear.
    ///   - title: Button title text.
    ///   - role: Optional button role.
    ///   - disabled: Whether the button is disabled.
    ///   - action: Action invoked when the button is tapped.
    public init(
        placement: ToolbarItemPlacement,
        title: String,
        role: ButtonRole? = nil,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) where Label == Text {
        self.init(placement: placement, role: role, disabled: disabled, action: action) {
            Text(title)
        }
    }

    public var body: some View {
        ToolbarItem(placement: placement) {
            Button(role: role, action: action) {
                label()
            }
            .disabled(isDisabled)
        }
    }
}

#if DEBUG
private struct ReusableToolbarItem_Previews: PreviewProvider {
    struct DemoView: View {
        @State private var count = 0
        var body: some View {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Count: \(count)")
                }
                .navigationTitle("Toolbar Demo")
                .toolbar {
                    ReusableToolbarItem(placement: .topBarTrailing, systemImage: "plus") {
                        count += 1
                    }
                    ReusableToolbarItem(placement: .topBarLeading, title: "Reset", role: .destructive, disabled: count == 0) {
                        count = 0
                    }
                }
            }
        }
    }

    static var previews: some View {
        DemoView()
    }
}
#endif
