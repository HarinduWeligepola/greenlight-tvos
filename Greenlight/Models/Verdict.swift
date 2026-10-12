//
//  Verdict.swift
//  Greenlight
//
//  Persisted with SwiftData so a household's picks survive app launches and
//  can be surfaced on the history screen.
//

import Foundation
import SwiftData

@Model
final class Verdict {
    var id: UUID = UUID()
    var filmTitle: String = ""
    var filmYear: Int = 0
    var filmGenre: String = ""
    var filmMotif: String = "film"
    var filmTintHex: Int = 0
    /// Names of everyone who greenlit it, in seat order.
    var playerNames: [String] = []
    /// Seat indices, so the history row can reproduce each player's colour.
    var playerSeats: [Int] = []
    /// How many films the room considered before agreeing.
    var filmsConsidered: Int = 0
    /// True when every player said yes. False when the room settled on the
    /// highest-scoring film instead of reaching a clean sweep.
    var isUnanimous: Bool = true
    var yesVotes: Int = 0
    var totalVotes: Int = 0
    var decidedAt: Date = Date()

    init(
        film: Film,
        players: [Player],
        filmsConsidered: Int,
        isUnanimous: Bool = true,
        yesVotes: Int = 0,
        totalVotes: Int = 0,
        decidedAt: Date = Date()
    ) {
        self.id = UUID()
        self.filmTitle = film.title
        self.filmYear = film.year
        self.filmGenre = film.genre
        self.filmMotif = film.motif
        self.filmTintHex = Int(film.tintHex)
        self.playerNames = players.map(\.name)
        self.playerSeats = players.map(\.seat)
        self.filmsConsidered = filmsConsidered
        self.isUnanimous = isUnanimous
        self.yesVotes = yesVotes
        self.totalVotes = totalVotes
        self.decidedAt = decidedAt
    }
}
