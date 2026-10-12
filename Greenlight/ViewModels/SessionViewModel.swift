//
//  SessionViewModel.swift
//  Greenlight
//
//  All game state and rules for one sitting. Views read from this object and
//  send it intents; they hold no rules of their own.
//

import SwiftUI
import Observation
import SwiftData

enum SessionPhase: Equatable {
    case lobby
    case voting
    case reveal
    case topPicks
    case history
}

@Observable
final class SessionViewModel {

    // MARK: - Roster

    /// Six fixed seats. A seat keeps its accent colour whether or not it is
    /// playing, so colours never shuffle between rounds.
    private(set) var roster: [Player] = (0..<6).map {
        Player(name: SessionViewModel.defaultNames[$0], seat: $0)
    }
    private(set) var activeSeats: Set<Int> = [0, 1, 2]

    static let defaultNames = ["Harindu", "Hiruna", "Hafsa", "Sakith", "Razeen", "Bathiya"]

    init() {
        refreshTags()
    }

    var players: [Player] {
        roster.filter { activeSeats.contains($0.seat) }.sorted { $0.seat < $1.seat }
    }

    var canStart: Bool { players.count >= 2 }

    func toggleSeat(_ seat: Int) {
        if activeSeats.contains(seat) {
            // Never drop below two players: the app is meaningless solo.
            guard activeSeats.count > 2 else { return }
            activeSeats.remove(seat)
        } else {
            activeSeats.insert(seat)
        }
    }

    func rename(seat: Int, to name: String) {
        guard let index = roster.firstIndex(where: { $0.seat == seat }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        roster[index].name = trimmed.isEmpty ? SessionViewModel.defaultNames[seat] : trimmed
        refreshTags()
    }

    /// Gives every player the shortest prefix of their name that nobody else
    /// in the roster shares, up to three characters. Three housemates whose
    /// names all begin with H would otherwise wear identical tokens.
    private func refreshTags() {
        for index in roster.indices {
            let others = roster.indices.filter { $0 != index }
            var chosen = Player.prefix(of: roster[index].name, length: 3)

            for length in 1...3 {
                let candidate = Player.prefix(of: roster[index].name, length: length)
                let clashes = others.contains { other in
                    Player.prefix(of: roster[other].name, length: length) == candidate
                }
                if !clashes {
                    chosen = candidate
                    break
                }
            }
            roster[index].tag = chosen
        }
    }

    // MARK: - Session state

    private(set) var phase: SessionPhase = .lobby
    private(set) var deck: [Film] = []
    private(set) var filmIndex: Int = 0
    /// Votes cast on the current film, in `voteOrder`.
    private(set) var votes: [Bool] = []
    private(set) var filmsConsidered: Int = 0
    private(set) var greenlitFilm: Film?
    /// Every film the room has voted on this session, newest last.
    private(set) var tallies: [FilmTally] = []
    /// False when the room settled on the highest-scoring film rather than
    /// reaching a clean sweep. Drives the wording and colour of the reveal.
    private(set) var isUnanimousWin = true
    /// "4 of 5 agreed" from the film just rejected, shown without naming anyone.
    private(set) var nearMiss: (yes: Int, total: Int)?
    private(set) var hasSavedVerdict = false

    /// The film currently on the table.
    var currentFilm: Film? {
        guard deck.indices.contains(filmIndex) else { return nil }
        return deck[filmIndex]
    }

    /// Voting order rotates each round so the same person is not always first.
    var voteOrder: [Player] {
        let people = players
        guard !people.isEmpty else { return [] }
        let offset = filmsConsidered % people.count
        return Array(people[offset...] + people[..<offset])
    }

    /// Whose turn it is to press.
    var currentVoter: Player? {
        guard votes.count < voteOrder.count else { return nil }
        return voteOrder[votes.count]
    }

    var progressText: String {
        "Film \(min(filmIndex + 1, deck.count)) of \(deck.count)"
    }

    // MARK: - Ranking
    //
    // A film that nobody fully agreed on is still useful information. Sorting
    // what the room has seen by approval turns a dead end into a shortlist.

    /// Everything voted on, best supported first. Ties break towards the film
    /// the room saw first, so an early favourite is not demoted by later ties.
    var rankedPicks: [FilmTally] {
        tallies.enumerated()
            .sorted { left, right in
                if left.element.yes != right.element.yes {
                    return left.element.yes > right.element.yes
                }
                if left.element.score != right.element.score {
                    return left.element.score > right.element.score
                }
                return left.offset < right.offset
            }
            .map(\.element)
    }

    /// The strongest films other than the one that was greenlit. A film
    /// nobody voted for is not "in the running", so zero-vote films are cut.
    var runnersUp: [FilmTally] {
        rankedPicks
            .filter { $0.film.id != greenlitFilm?.id && $0.yes > 0 }
            .prefix(3)
            .map { $0 }
    }

    /// The film to suggest when no clean sweep happened.
    var leadingPick: FilmTally? { rankedPicks.first }

    // MARK: - Intents

    func start() {
        deck = FilmCatalog.deck(count: 12)
        filmIndex = 0
        votes = []
        filmsConsidered = 0
        greenlitFilm = nil
        nearMiss = nil
        tallies = []
        isUnanimousWin = true
        hasSavedVerdict = false
        phase = .voting
    }

    /// Records one player's decision on the current film and, once everyone
    /// has pressed, resolves the round.
    func castVote(approve: Bool) {
        guard phase == .voting, currentVoter != nil else { return }
        votes.append(approve)
        guard votes.count == voteOrder.count else { return }
        resolveRound()
    }

    private func resolveRound() {
        let yesCount = votes.filter { $0 }.count
        filmsConsidered += 1

        if let film = currentFilm {
            tallies.append(FilmTally(film: film, yes: yesCount, total: votes.count))
        }

        if yesCount == votes.count, let film = currentFilm {
            greenlitFilm = film
            isUnanimousWin = true
            nearMiss = nil
            phase = .reveal
        } else {
            nearMiss = (yes: yesCount, total: votes.count)
            advanceToNextFilm()
        }
    }

    private func advanceToNextFilm() {
        votes = []
        filmIndex += 1
        if filmIndex >= deck.count {
            phase = .topPicks
        }
    }

    /// Keeps the same room but deals a fresh deck.
    func playAgain() {
        start()
    }

    /// Accepts the highest-scoring film when the room never reached a clean
    /// sweep. Reuses the reveal, which reads differently for a settled pick.
    func settle(on tally: FilmTally) {
        greenlitFilm = tally.film
        isUnanimousWin = false
        hasSavedVerdict = false
        phase = .reveal
    }

    func returnToLobby() {
        phase = .lobby
        greenlitFilm = nil
        votes = []
        nearMiss = nil
    }

    func showHistory() { phase = .history }
    func dismissHistory() { phase = .lobby }

    // MARK: - UI verification hook
    //
    // Passing `-glDemoPhase voting|reveal|exhausted|history` on launch jumps
    // straight to a screen. Used by the screenshot pass during UI testing;
    // it has no effect on a normal launch.

    func applyLaunchOverrideIfNeeded() {
        guard let requested = UserDefaults.standard.string(forKey: "glDemoPhase") else { return }

        switch requested {
        case "voting":
            start()
        case "reveal":
            start()
            let total = players.count
            for (offset, film) in deck.prefix(4).enumerated() where offset > 0 {
                tallies.append(FilmTally(film: film, yes: max(0, total - offset), total: total))
            }
            if let winner = deck.first {
                tallies.append(FilmTally(film: winner, yes: total, total: total))
                greenlitFilm = winner
            }
            filmsConsidered = 4
            isUnanimousWin = true
            phase = .reveal
        case "toppicks":
            start()
            for (offset, film) in deck.enumerated() {
                let total = players.count
                let yes = max(0, total - (offset % (total + 1)))
                tallies.append(FilmTally(film: film, yes: yes, total: total))
            }
            tallies = tallies.filter { !$0.isUnanimous }
            filmIndex = deck.count
            filmsConsidered = deck.count
            phase = .topPicks
        case "history":
            phase = .history
        default:
            break
        }
    }

    // MARK: - Persistence

    /// Writes the agreed film to the store exactly once per reveal.
    func saveVerdict(into context: ModelContext) {
        guard !hasSavedVerdict, let film = greenlitFilm else { return }
        let tally = tallies.first { $0.film.id == film.id }
        let verdict = Verdict(
            film: film,
            players: players,
            filmsConsidered: filmsConsidered,
            isUnanimous: isUnanimousWin,
            yesVotes: tally?.yes ?? players.count,
            totalVotes: tally?.total ?? players.count
        )
        context.insert(verdict)
        try? context.save()
        hasSavedVerdict = true
    }
}
