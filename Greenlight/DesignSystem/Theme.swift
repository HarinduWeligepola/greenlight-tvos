//
//  Theme.swift
//  Greenlight
//
//  The single source of truth for colour, type and spacing.
//
//  Design rule that governs this whole file: `Theme.green` means approval
//  and nothing else. It is never used for focus, navigation or decoration,
//  so that the greenlight reveal is the only moment the colour appears.
//

import SwiftUI

enum Theme {

    // MARK: - Surfaces

    /// Screen background. Deliberately not pure black: `#000` smears on OLED
    /// panels during motion and removes the sense of depth between layers.
    static let base = Color(hex: 0x0A0B0C)
    /// Resting card surface.
    static let card = Color(hex: 0x14161A)
    /// Surface of a card that currently holds focus.
    static let focused = Color(hex: 0x1E2228)
    /// Hairline borders and dividers.
    static let hairline = Color(hex: 0x2A2F36)

    // MARK: - Text

    /// Warm off-white rather than pure white, which glares at viewing distance.
    static let textPrimary = Color(hex: 0xF4F6F5)
    static let textSecondary = Color(hex: 0xA8B0AE)
    static let textTertiary = Color(hex: 0x6B7370)

    // MARK: - Signal

    /// Approval. Reserved — see the note at the top of this file.
    static let green = Color(hex: 0x2BE06B)
    /// Peak of the reveal flash.
    static let greenPeak = Color(hex: 0x5CFF95)
    /// Pressed and underlay states.
    static let greenDeep = Color(hex: 0x0F7A3C)
    /// Rejection. A dim slate, not red: saturated red blooms on TV panels and
    /// passing on a film should not feel like an error.
    static let pass = Color(hex: 0x4E565E)

    // MARK: - Player identity

    /// Six accents sweeping the spectrum from amber to cyan, deliberately
    /// skipping green so no player colour can be confused with a verdict.
    static let playerColors: [Color] = [
        Color(hex: 0xF5A623),   // amber
        Color(hex: 0xFF6F59),   // coral
        Color(hex: 0xF2567E),   // rose
        Color(hex: 0xA77BFF),   // violet
        Color(hex: 0x5B8DEF),   // blue
        Color(hex: 0x35C6E8)    // cyan
    ]

    static func playerColor(_ index: Int) -> Color {
        playerColors[((index % playerColors.count) + playerColors.count) % playerColors.count]
    }

    // MARK: - Metrics

    enum Radius {
        static let card: CGFloat = 36
        static let panel: CGFloat = 28
        static let control: CGFloat = 22
    }

    enum Space {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 16
        static let md: CGFloat = 28
        static let lg: CGFloat = 48
        static let xl: CGFloat = 72
    }

    // MARK: - Type scale
    //
    // tvOS is read from roughly three metres away, so the scale starts far
    // larger than a handset scale would.

    enum Font {
        static func display(_ size: CGFloat = 96) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        static func title(_ size: CGFloat = 56) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        static func headline(_ size: CGFloat = 38) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        static func body(_ size: CGFloat = 30) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
        static func caption(_ size: CGFloat = 24) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        /// Wide letter-spaced labels are applied with `.kerning()` at the call site.
        static func label(_ size: CGFloat = 22) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
    }
}

// MARK: - Hex convenience

extension Color {
    /// Builds a colour from a 0xRRGGBB literal so the palette reads the same
    /// here as it does in the design documentation.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
