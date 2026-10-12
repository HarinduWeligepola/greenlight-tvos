//
//  FilmPosterView.swift
//  Greenlight
//
//  Posters are generated from the film's motif and tint rather than bundled
//  as artwork, so the prototype carries no third-party images and every card
//  sits correctly inside the app's palette.
//

import SwiftUI

struct FilmPosterView: View {
    let film: Film
    var cornerRadius: CGFloat = Theme.Radius.panel

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)

            ZStack {
                LinearGradient(
                    colors: [
                        film.tint.opacity(0.85),
                        film.tint.opacity(0.30),
                        Theme.base
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: film.motif)
                    .font(.system(size: side * 0.62, weight: .light))
                    .foregroundStyle(Theme.base.opacity(0.28))
                    .offset(x: geometry.size.width * 0.14, y: geometry.size.height * 0.16)

                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    Text(film.genre.uppercased())
                        .font(Theme.Font.label(20))
                        .kerning(3)
                        .foregroundStyle(Theme.textPrimary.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Space.md)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.5)
        }
    }
}
