//
//  Film.swift
//  Greenlight
//

import SwiftUI

/// A candidate for tonight. Artwork is generated from `motif` and `tintHex`
/// rather than bundled, so the prototype ships no third-party poster images.
struct Film: Identifiable, Hashable {
    let id: UUID
    let title: String
    let year: Int
    /// Runtime in minutes.
    let runtime: Int
    let genre: String
    /// A one-line original logline.
    let logline: String
    /// SF Symbol used as the poster motif.
    let motif: String
    let tintHex: UInt32

    init(
        id: UUID = UUID(),
        title: String,
        year: Int,
        runtime: Int,
        genre: String,
        logline: String,
        motif: String,
        tintHex: UInt32
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.runtime = runtime
        self.genre = genre
        self.logline = logline
        self.motif = motif
        self.tintHex = tintHex
    }

    var tint: Color { Color(hex: tintHex) }

    var runtimeText: String {
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours == 0 { return "\(minutes)m" }
        return minutes == 0 ? "\(hours)h" : "\(hours)h \(minutes)m"
    }
}
