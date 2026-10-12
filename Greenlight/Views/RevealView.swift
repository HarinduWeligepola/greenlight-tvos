//
//  RevealView.swift
//  Greenlight
//
//  The payoff, in two forms.
//
//  A clean sweep floods the frame green and opens the aperture fully — the
//  only place in the app where green fills the screen. A film the room
//  *settled* on reads the same way structurally but in neutral tone with the
//  aperture only part open, because nothing was unanimously approved and the
//  palette rule says green cannot claim otherwise.
//

import SwiftUI
import SwiftData

struct RevealView: View {
    @Bindable var session: SessionViewModel
    @Environment(\.modelContext) private var context

    @State private var apertureOpen: CGFloat = 0
    @State private var flood: CGFloat = 0
    @State private var contentIn = false

    private var isSweep: Bool { session.isUnanimousWin }
    private var accent: Color { isSweep ? Theme.green : Theme.textPrimary }

    var body: some View {
        ZStack {
            floodBackground

            VStack(spacing: Theme.Space.sm) {
                ApertureMark(openAmount: apertureOpen, intensity: isSweep ? 1 + flood : 0.6)
                    .frame(width: 190, height: 190)

                Text(isSweep ? "GREENLIT" : "TONIGHT'S PICK")
                    .font(Theme.Font.label(30))
                    .kerning(12)
                    .foregroundStyle(accent)
                    .opacity(contentIn ? 1 : 0)

                if let film = session.greenlitFilm {
                    Text(film.title)
                        .font(Theme.Font.display(96))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.55)
                        .padding(.horizontal, Theme.Space.xl)
                        .opacity(contentIn ? 1 : 0)
                        .offset(y: contentIn ? 0 : 28)

                    Text("\(String(film.year))  ·  \(film.runtimeText)  ·  \(film.genre)")
                        .font(Theme.Font.body(28))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(contentIn ? 1 : 0)
                }

                agreedBy
                    .padding(.top, Theme.Space.xs)

                Text(summaryLine)
                    .font(Theme.Font.caption(24))
                    .foregroundStyle(Theme.textTertiary)
                    .opacity(contentIn ? 1 : 0)

                if isSweep, !session.runnersUp.isEmpty {
                    runnersUp
                        .padding(.top, Theme.Space.md)
                        .opacity(contentIn ? 1 : 0)
                }

                actions
                    .padding(.top, Theme.Space.md)
                    .opacity(contentIn ? 1 : 0)
            }
            .padding(Theme.Space.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onExitCommand { session.returnToLobby() }
        .task { await runReveal() }
    }

    // MARK: - Pieces

    private var floodBackground: some View {
        ZStack {
            Theme.base
            RadialGradient(
                colors: isSweep
                    ? [
                        Theme.green.opacity(0.55 * flood),
                        Theme.greenDeep.opacity(0.28 * flood),
                        .clear
                    ]
                    : [
                        Theme.focused.opacity(0.9 * flood),
                        Theme.card.opacity(0.5 * flood),
                        .clear
                    ],
                center: .center,
                startRadius: 0,
                endRadius: 1100
            )
        }
        .ignoresSafeArea()
    }

    private var summaryLine: String {
        if isSweep {
            let films = session.filmsConsidered
            return "Everybody agreed, after \(films) \(films == 1 ? "film" : "films")"
        }
        guard let film = session.greenlitFilm,
              let tally = session.tallies.first(where: { $0.film.id == film.id })
        else { return "The closest the room got" }
        return "\(tally.scoreText) agreed — the closest the room got"
    }

    private var agreedBy: some View {
        HStack(spacing: Theme.Space.sm) {
            ForEach(session.players) { player in
                PlayerToken(player: player, size: 58, isActive: false, hasVoted: true)
            }
        }
        .opacity(contentIn ? 1 : 0)
        .scaleEffect(contentIn ? 1 : 0.9)
    }

    /// What the room nearly picked. Shown only after a clean sweep, where it
    /// reads as "here is the rest of the shortlist" rather than as a consolation.
    private var runnersUp: some View {
        VStack(spacing: Theme.Space.xs) {
            Text("ALSO IN THE RUNNING")
                .font(Theme.Font.label(18))
                .kerning(4)
                .foregroundStyle(Theme.textTertiary)

            HStack(spacing: Theme.Space.sm) {
                ForEach(session.runnersUp) { tally in
                    HStack(spacing: 12) {
                        Image(systemName: tally.film.motif)
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(Theme.textSecondary)
                        Text(tally.film.title)
                            .font(Theme.Font.caption(22))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                        Text(tally.scoreText)
                            .font(Theme.Font.caption(20))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .padding(.horizontal, Theme.Space.sm)
                    .padding(.vertical, 12)
                    .glassPanel(cornerRadius: 20)
                }
            }
        }
    }

    private var actions: some View {
        HStack(spacing: Theme.Space.md) {
            Button("Another round") { session.playAgain() }
                .buttonStyle(.glassPill(tint: isSweep ? Theme.green : Theme.textPrimary, prominent: isSweep))

            Button("Finish") { session.returnToLobby() }
                .buttonStyle(.glassPill(tint: Theme.textSecondary))
        }
    }

    // MARK: - Choreography
    //
    // Four beats: the room floods, the aperture opens, the title lands, the
    // verdict is written to the store.

    private func runReveal() async {
        withAnimation(.easeOut(duration: 0.45)) { flood = 1 }

        try? await Task.sleep(for: .milliseconds(120))
        withAnimation(.spring(response: 0.85, dampingFraction: 0.62)) {
            apertureOpen = isSweep ? 1 : 0.5
        }

        try? await Task.sleep(for: .milliseconds(260))
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { contentIn = true }

        session.saveVerdict(into: context)
    }
}
