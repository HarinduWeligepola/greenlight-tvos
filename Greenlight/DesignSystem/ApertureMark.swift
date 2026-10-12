//
//  ApertureMark.swift
//  Greenlight
//
//  The Greenlight brand mark, drawn as vector geometry rather than shipped
//  as a bitmap so it can be animated. The aperture opens when a film is
//  greenlit, which is the single most important moment in the app.
//

import SwiftUI

// MARK: - Blade geometry

/// Six iris blades filling the ring between the housing edge and a central
/// opening. Each blade is the region between a chord tangent to the opening
/// circle and the minor arc of the housing circle beyond it; six of them
/// rotated by 60° leave a regular hexagonal opening.
struct ApertureBlades: Shape {
    /// 0 = closed to the core, 1 = fully retracted.
    var openAmount: CGFloat
    var bladeCount: Int = 6

    /// Opening inradius as a fraction of the housing radius. The upper bound
    /// stays below cos(30°) so adjacent blades keep overlapping and the
    /// opening stays a clean hexagon.
    static func openingRatio(_ openAmount: CGFloat) -> CGFloat {
        let clamped = min(max(openAmount, 0), 1)
        return 0.26 + (0.80 - 0.26) * clamped
    }

    var animatableData: CGFloat {
        get { openAmount }
        set { openAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let housing = min(rect.width, rect.height) / 2
        guard housing > 0 else { return Path() }

        let opening = housing * ApertureBlades.openingRatio(openAmount)
        guard opening < housing else { return Path() }

        let halfSweep = acos(opening / housing)
        var path = Path()

        for index in 0..<bladeCount {
            let phi = (CGFloat(index) / CGFloat(bladeCount)) * 2 * .pi - .pi / 2
            let start = phi - halfSweep
            let end = phi + halfSweep

            path.move(to: CGPoint(
                x: centre.x + housing * cos(start),
                y: centre.y + housing * sin(start)
            ))
            path.addArc(
                center: centre,
                radius: housing,
                startAngle: .radians(Double(start)),
                endAngle: .radians(Double(end)),
                clockwise: false
            )
            path.closeSubpath()   // the chord, which forms the blade edge
        }
        return path
    }
}

/// Just the leading edge of each blade, stroked as a highlight so the blades
/// read as separate overlapping plates rather than one solid ring.
struct ApertureBladeEdges: Shape {
    var openAmount: CGFloat
    var bladeCount: Int = 6

    var animatableData: CGFloat {
        get { openAmount }
        set { openAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let housing = min(rect.width, rect.height) / 2
        guard housing > 0 else { return Path() }

        let opening = housing * ApertureBlades.openingRatio(openAmount)
        guard opening < housing else { return Path() }

        let halfSweep = acos(opening / housing)
        var path = Path()

        for index in 0..<bladeCount {
            let phi = (CGFloat(index) / CGFloat(bladeCount)) * 2 * .pi - .pi / 2
            path.move(to: CGPoint(
                x: centre.x + housing * cos(phi - halfSweep),
                y: centre.y + housing * sin(phi - halfSweep)
            ))
            path.addLine(to: CGPoint(
                x: centre.x + housing * cos(phi + halfSweep),
                y: centre.y + housing * sin(phi + halfSweep)
            ))
        }
        return path
    }
}

// MARK: - Mark

/// The complete brand mark: outer ring, graphite blades, glowing green core.
struct ApertureMark: View {
    /// 0 = resting, 1 = greenlit and fully open.
    var openAmount: CGFloat = 0
    /// Brightness of the core bloom, raised during the reveal.
    var intensity: CGFloat = 1
    var showsRing: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let housing = side * 0.80

            ZStack {
                if showsRing {
                    Circle()
                        .strokeBorder(Theme.green.opacity(0.55), lineWidth: max(2, side * 0.012))
                        .frame(width: side, height: side)
                }

                // Core bloom, sitting behind the blades so it only escapes
                // through the opening.
                Circle()
                    .fill(Theme.green)
                    .frame(width: housing * 0.55, height: housing * 0.55)
                    .blur(radius: side * 0.09)
                    .opacity(0.55 * intensity)

                ZStack {
                    // Inscribed in the hexagonal opening, so the visible core
                    // reads as a circle exactly as the brand mark does.
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.greenPeak, Theme.green, Theme.greenDeep],
                                center: .center,
                                startRadius: 0,
                                endRadius: housing * ApertureBlades.openingRatio(openAmount) * 0.62
                            )
                        )
                        .frame(
                            width: housing * ApertureBlades.openingRatio(openAmount),
                            height: housing * ApertureBlades.openingRatio(openAmount)
                        )

                    ApertureBlades(openAmount: openAmount)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x343A42), Color(hex: 0x1C2026)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    ApertureBladeEdges(openAmount: openAmount)
                        .stroke(Color(hex: 0x5A626C).opacity(0.9), lineWidth: max(1, side * 0.005))
                }
                .frame(width: housing, height: housing)
                .clipShape(Circle())
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Wordmark

/// Mark plus name, used on the lobby and the reveal.
struct GreenlightWordmark: View {
    var markSize: CGFloat = 120
    var openAmount: CGFloat = 0

    var body: some View {
        HStack(spacing: Theme.Space.md) {
            ApertureMark(openAmount: openAmount)
                .frame(width: markSize, height: markSize)

            Text("GREENLIGHT")
                .font(.system(size: markSize * 0.46, weight: .bold, design: .rounded))
                .kerning(markSize * 0.055)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    ZStack {
        Theme.base.ignoresSafeArea()
        GreenlightWordmark(markSize: 200)
    }
}
