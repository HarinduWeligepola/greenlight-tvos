//
//  GlassButton.swift
//  Greenlight
//
//  Button styles built on the app's glass modifiers. They read the focus
//  state from the environment rather than requiring every call site to own
//  a `@FocusState`, which keeps the screens declarative.
//

import SwiftUI

/// Pill control used for every action in the app.
struct GlassButtonStyle: ButtonStyle {
    var tint: Color = Theme.textPrimary
    /// A prominent button fills with its tint on focus and flips to dark text.
    var prominent: Bool = false
    var horizontalPadding: CGFloat = 52
    var verticalPadding: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        StyleBody(
            configuration: configuration,
            tint: tint,
            prominent: prominent,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
    }

    private struct StyleBody: View {
        let configuration: Configuration
        let tint: Color
        let prominent: Bool
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat

        @Environment(\.isFocused) private var isFocused
        @Environment(\.self) private var environment

        var body: some View {
            configuration.label
                .font(Theme.Font.headline(32))
                .foregroundStyle(labelColour)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .glassAction(tint: tint, isFocused: isFocused)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
        }

        /// A focused control fills with its tint, so the label has to flip to
        /// dark on light tints. Deciding this from luminance rather than from
        /// a flag means a new tint can never ship unreadable.
        private var labelColour: Color {
            guard isFocused else { return Theme.textPrimary }
            let resolved = tint.resolve(in: environment)
            let luminance = 0.2126 * Double(resolved.red)
                + 0.7152 * Double(resolved.green)
                + 0.0722 * Double(resolved.blue)
            return luminance > 0.45 ? Theme.base : Theme.textPrimary
        }
    }
}

/// Large focusable surface used for lobby seats and history rows.
struct GlassCardButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = Theme.Radius.panel

    func makeBody(configuration: Configuration) -> some View {
        StyleBody(configuration: configuration, cornerRadius: cornerRadius)
    }

    private struct StyleBody: View {
        let configuration: Configuration
        let cornerRadius: CGFloat

        @Environment(\.isFocused) private var isFocused

        var body: some View {
            configuration.label
                .glassCard(cornerRadius: cornerRadius, isFocused: isFocused)
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glassPill: GlassButtonStyle { GlassButtonStyle() }

    static func glassPill(tint: Color, prominent: Bool = false) -> GlassButtonStyle {
        GlassButtonStyle(tint: tint, prominent: prominent)
    }
}

extension ButtonStyle where Self == GlassCardButtonStyle {
    static var glassSurface: GlassCardButtonStyle { GlassCardButtonStyle() }
}
