//
//  LiquidGlass.swift
//  Greenlight
//
//  Custom view modifiers that wrap the system Liquid Glass material in a
//  single vocabulary for the app, with a graceful material fallback for
//  builds running against an older SDK.
//
//  These are the app's custom SwiftUI modifiers: every panel, card and
//  control in Greenlight is styled through `glassPanel`, `glassCard` or
//  `glassAction` rather than by applying effects ad hoc at the call site.
//

import SwiftUI

// MARK: - Panel

/// A resting glass surface: toolbars, roster seats, history rows.
struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.panel
    var isFocused: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                if #available(tvOS 26.0, *) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.clear)
                        .glassEffect(
                            .regular,
                            in: .rect(cornerRadius: cornerRadius, style: .continuous)
                        )
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay {
                // A hairline rim keeps glass legible against the near-black
                // background, where the material alone has little to refract.
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        isFocused ? Theme.textPrimary.opacity(0.45) : Theme.hairline.opacity(0.9),
                        lineWidth: isFocused ? 3 : 1.5
                    )
            }
            .shadow(color: .black.opacity(isFocused ? 0.55 : 0.0), radius: 40, y: 18)
    }
}

// MARK: - Card

/// The large focusable surface used for a film. Carries the focus treatment
/// for the whole app: lift, scale and an off-white rim — never green, so that
/// "where the cursor is" is never confused with "this is approved".
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.card
    var isFocused: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                if #available(tvOS 26.0, *) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isFocused ? Theme.focused.opacity(0.55) : Theme.card.opacity(0.55))
                        .glassEffect(
                            .regular,
                            in: .rect(cornerRadius: cornerRadius, style: .continuous)
                        )
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isFocused ? Theme.focused : Theme.card)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        isFocused ? Theme.textPrimary.opacity(0.5) : Theme.hairline,
                        lineWidth: isFocused ? 3 : 1.5
                    )
            }
            .scaleEffect(isFocused ? 1.04 : 1.0)
            .shadow(color: .black.opacity(0.6), radius: isFocused ? 60 : 24, y: isFocused ? 28 : 10)
            .animation(.spring(response: 0.38, dampingFraction: 0.78), value: isFocused)
    }
}

// MARK: - Action

/// A tinted, interactive glass control. `tint` is passed through to the
/// system material so the greenlight button genuinely refracts green.
struct GlassActionModifier: ViewModifier {
    var tint: Color
    var isFocused: Bool
    var cornerRadius: CGFloat = Theme.Radius.control

    func body(content: Content) -> some View {
        content
            .background {
                if #available(tvOS 26.0, *) {
                    Capsule(style: .continuous)
                        .fill(.clear)
                        .glassEffect(
                            .regular.tint(tint.opacity(isFocused ? 0.85 : 0.30)).interactive(),
                            in: .capsule
                        )
                } else {
                    Capsule(style: .continuous)
                        .fill(tint.opacity(isFocused ? 0.85 : 0.25))
                        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                }
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(
                        isFocused ? Theme.textPrimary.opacity(0.85) : tint.opacity(0.55),
                        lineWidth: isFocused ? 3 : 1.5
                    )
            }
            .scaleEffect(isFocused ? 1.06 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.72), value: isFocused)
    }
}

// MARK: - Call sites

extension View {
    /// Resting glass surface.
    func glassPanel(cornerRadius: CGFloat = Theme.Radius.panel, isFocused: Bool = false) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius, isFocused: isFocused))
    }

    /// Large focusable glass card.
    func glassCard(cornerRadius: CGFloat = Theme.Radius.card, isFocused: Bool = false) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, isFocused: isFocused))
    }

    /// Tinted interactive glass control.
    func glassAction(tint: Color, isFocused: Bool, cornerRadius: CGFloat = Theme.Radius.control) -> some View {
        modifier(GlassActionModifier(tint: tint, isFocused: isFocused, cornerRadius: cornerRadius))
    }
}
