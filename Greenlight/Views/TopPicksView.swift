//
//  TopPicksView.swift
//  Greenlight
//
//  Shown when the deck runs out without a clean sweep. Rather than a dead
//  end, the room gets a shortlist: every film it saw, ranked by how much of
//  the room approved. Nothing here is green — nothing was unanimous — so the
//  leading pick is presented in neutral type and the room chooses to settle.
//

import SwiftUI

struct TopPicksView: View {
    @Bindable var session: SessionViewModel

    private enum Field: Hashable { case settle }
    @FocusState private var focus: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if let leader = session.leadingPick {
                LeadingPickCard(tally: leader)
                    .padding(.top, Theme.Space.md)

                let alsoClose = session.rankedPicks
                    .dropFirst()
                    .filter { $0.yes > 0 }
                    .prefix(4)

                if !alsoClose.isEmpty {
                    Text("ALSO CLOSE")
                        .font(Theme.Font.label(20))
                        .kerning(4)
                        .foregroundStyle(Theme.textTertiary)
                        .padding(.top, Theme.Space.md)
                        .padding(.bottom, Theme.Space.xs)

                    HStack(spacing: Theme.Space.sm) {
                        ForEach(Array(alsoClose)) { tally in
                            RunnerUpChip(tally: tally)
                        }
                    }
                }

                actions(for: leader)
                    .padding(.top, Theme.Space.lg)
            } else {
                Text("Nothing was voted on.")
                    .font(Theme.Font.body(30))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, Theme.Space.md)

                actions(for: nil)
                    .padding(.top, Theme.Space.lg)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 90)
        .padding(.vertical, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .defaultFocus($focus, .settle)
        .onExitCommand { session.returnToLobby() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No clean sweep")
                .font(Theme.Font.display(72))
                .foregroundStyle(Theme.textPrimary)
            Text("All \(session.deck.count) films went round the room and none of them got everybody. Here is what came closest.")
                .font(Theme.Font.body(28))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 1500, alignment: .leading)
        }
    }

    @ViewBuilder
    private func actions(for leader: FilmTally?) -> some View {
        HStack(spacing: Theme.Space.md) {
            if let leader {
                Button {
                    session.settle(on: leader)
                } label: {
                    Label("Watch \(leader.film.title)", systemImage: "play.fill")
                }
                .buttonStyle(.glassPill(tint: Theme.textPrimary))
                .focused($focus, equals: .settle)
            }

            Button("Deal a new deck") { session.playAgain() }
                .buttonStyle(.glassPill(tint: Theme.textSecondary))

            Button("Change the room") { session.returnToLobby() }
                .buttonStyle(.glassPill(tint: Theme.textSecondary))
        }
    }
}

// MARK: - Leader

private struct LeadingPickCard: View {
    let tally: FilmTally

    var body: some View {
        HStack(spacing: Theme.Space.lg) {
            FilmPosterView(film: tally.film)
                .frame(width: 260, height: 350)
                .shadow(color: .black.opacity(0.7), radius: 40, y: 18)

            VStack(alignment: .leading, spacing: Theme.Space.sm) {
                ApprovalBar(tally: tally, width: 420)

                Text(tally.film.title)
                    .font(Theme.Font.title(54))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text("\(String(tally.film.year))  ·  \(tally.film.runtimeText)  ·  \(tally.film.genre)")
                    .font(Theme.Font.caption(24))
                    .foregroundStyle(Theme.textTertiary)

                Text(tally.film.logline)
                    .font(Theme.Font.body(28))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 700, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Space.md)
        .glassCard()
    }
}

/// How much of the room approved, as a proportion rather than a colour —
/// green is reserved for a clean sweep, which by definition did not happen.
private struct ApprovalBar: View {
    let tally: FilmTally
    let width: CGFloat

    var body: some View {
        HStack(spacing: Theme.Space.sm) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.hairline)
                Capsule()
                    .fill(Theme.textPrimary.opacity(0.85))
                    .frame(width: max(12, width * tally.score))
            }
            .frame(width: width, height: 14)

            Text("\(tally.scoreText) agreed")
                .font(Theme.Font.label(22))
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

// MARK: - Runners-up

private struct RunnerUpChip: View {
    let tally: FilmTally

    var body: some View {
        HStack(spacing: Theme.Space.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tally.film.tint.opacity(0.35))
                Image(systemName: tally.film.motif)
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Theme.textPrimary.opacity(0.85))
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(tally.film.title)
                    .font(Theme.Font.caption(24))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                Text(tally.scoreText)
                    .font(Theme.Font.caption(22))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Space.xs)
        .frame(width: 360, height: 104)
        .glassPanel(cornerRadius: 22)
    }
}
