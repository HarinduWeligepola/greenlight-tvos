//
//  Player.swift
//  Greenlight
//

import SwiftUI

/// One person in the room. `seat` fixes the accent colour so a player keeps
/// the same identity colour for the whole session.
struct Player: Identifiable, Hashable {
    let id: UUID
    var name: String
    let seat: Int
    /// Shortest prefix of `name` that is unique across the roster, assigned
    /// by the session. Several housemates can share a first letter, and a
    /// row of identical tokens would defeat the point of having them.
    var tag: String

    init(id: UUID = UUID(), name: String, seat: Int, tag: String = "") {
        self.id = id
        self.name = name
        self.seat = seat
        self.tag = tag.isEmpty ? Player.prefix(of: name, length: 1) : tag
    }

    var colour: Color { Theme.playerColor(seat) }

    /// First `length` characters of a name, capitalised.
    static func prefix(of name: String, length: Int) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "?" }
        return String(trimmed.prefix(length)).uppercased()
    }
}
