//
//  FilmTally.swift
//  Greenlight
//
//  What the room actually thought of one film. Every film that goes round
//  the table leaves one of these behind, which is what lets the app rank
//  the near-misses instead of throwing them away.
//

import Foundation

struct FilmTally: Identifiable, Hashable {
    let film: Film
    let yes: Int
    let total: Int

    var id: UUID { film.id }

    var isUnanimous: Bool { total > 0 && yes == total }

    /// Share of the room that approved, 0...1.
    var score: Double { total == 0 ? 0 : Double(yes) / Double(total) }

    var scoreText: String { "\(yes) of \(total)" }
}
