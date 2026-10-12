//
//  VotingView.swift
//  Greenlight
//
//  One film, one player at a time. The whole screen is driven by the Siri
//  Remote touch surface: swipe left to pass, swipe right to greenlight.
//  There is nothing to aim at and nothing to click, which is what makes the
//  remote comfortable to hand around a sofa.
//
//  Votes are never displayed as yes or no while the round is running — only
//  as a filled token in the player's colour — so the room cannot read how it
//  is leaning before the verdict lands.
//

import SwiftUI

struct VotingView: View {
    @Bindable var session: SessionViewModel

    @FocusState private var deckFocused: Bool
    /// Direction the current voter is leaning, for the hint pills.
    @State private var lean: Bool?
    /// The ✓ / ✕ stamp shown for a moment after a press.
    @State private var stamp: Bool?
    @State private var isResolving = false

    var body: some View {
        ZStack {
            if let film = session.currentFilm {
                content(for: film)
            }
            stampOverlay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .focusable(true)
        .focused($deckFocused)
        .onMoveCommand(perform: handleMove)
        .onExitCommand { session.returnToLobby() }
        .onAppear { deckFocused = true }
    }

    // MARK: - Layout

    @ViewBuilder
    private func content(for film: Film) -> some View {
        VStack(spacing: 0) {

            header

            Spacer(minLength: Theme.Space.md)

            HStack(alignment: .center, spacing: Theme.Space.xl) {
                FilmPosterView(film: film)
                    .frame(width: 420, height: 580)
                    .shadow(color: .black.opacity(0.7), radius: 48, y: 22)

                details(for: film)
            }
            .padding(Theme.Space.lg)
            .glassCard(isFocused: deckFocused)
            .id(film.id)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .scale(scale: 0.92).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: session.filmIndex)

            Spacer(minLength: Theme.Space.md)

            turnPrompt

            VoteProgressRail(order: session.voteOrder, votesCast: session.votes.count)
                .padding(.top, Theme.Space.sm)

            hintPills
                .padding(.top, Theme.Space.md)
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 56)
    }

    private var header: some View {
        HStack {
            Text(session.progressText.uppercased())
                .font(Theme.Font.label(22))
                .kerning(4)
                .foregroundStyle(Theme.textTertiary)

            Spacer()

            if let miss = session.nearMiss {
                Text("Last film: \(miss.yes) of \(miss.total) agreed")
                    .font(Theme.Font.caption(22))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, Theme.Space.md)
                    .padding(.vertical, 10)
                    .glassPanel(cornerRadius: 22)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: session.filmsConsidered)
    }

    private func details(for film: Film) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.sm) {
            Text(film.title)
                .font(Theme.Font.title(58))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            HStack(spacing: Theme.Space.sm) {
                metaChip(String(film.year))
                metaChip(film.runtimeText)
                metaChip(film.genre)
            }

            Text(film.logline)
                .font(Theme.Font.body(30))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Space.xs)
        }
        .frame(maxWidth: 560, alignment: .leading)
    }

    private func metaChip(_ text: String) -> some View {
        Text(text)
            .font(Theme.Font.caption(22))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background {
                Capsule().strokeBorder(Theme.hairline, lineWidth: 1.5)
            }
    }

    private var turnPrompt: some View {
        Group {
            if let voter = session.currentVoter {
                HStack(spacing: Theme.Space.sm) {
                    Text("Pass the remote to")
                        .font(Theme.Font.body(30))
                        .foregroundStyle(Theme.textTertiary)
                    Text(voter.name)
                        .font(Theme.Font.headline(36))
                        .foregroundStyle(voter.colour)
                }
                .id(voter.id)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.votes.count)
        .frame(height: 50)
    }

    private var hintPills: some View {
        HStack(spacing: Theme.Space.lg) {
            HintPill(
                systemImage: "arrow.left",
                title: "Pass",
                tint: Theme.pass,
                isLeaning: lean == false
            )
            HintPill(
                systemImage: "arrow.right",
                title: "Greenlight",
                tint: Theme.green,
                isLeaning: lean == true
            )
        }
    }

    private var stampOverlay: some View {
        Group {
            if let stamp {
                let colour = stamp ? Theme.green : Theme.pass
                Image(systemName: stamp ? "checkmark" : "xmark")
                    .font(.system(size: 220, weight: .heavy))
                    .foregroundStyle(colour)
                    .shadow(color: colour.opacity(0.6), radius: 60)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: stamp)
        .allowsHitTesting(false)
    }

    // MARK: - Input

    private func handleMove(_ direction: MoveCommandDirection) {
        guard !isResolving, session.phase == .voting else { return }

        switch direction {
        case .left:
            register(approve: false)
        case .right:
            register(approve: true)
        default:
            break
        }
    }

    private func register(approve: Bool) {
        isResolving = true
        lean = approve
        stamp = approve

        Task {
            try? await Task.sleep(for: .milliseconds(340))
            await MainActor.run {
                stamp = nil
                lean = nil
                session.castVote(approve: approve)
                isResolving = false
            }
        }
    }
}

// MARK: - Hint

private struct HintPill: View {
    let systemImage: String
    let title: String
    let tint: Color
    let isLeaning: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .bold))
            Text(title)
                .font(Theme.Font.headline(30))
        }
        .foregroundStyle(isLeaning ? Theme.base : Theme.textSecondary)
        .padding(.horizontal, 40)
        .padding(.vertical, 18)
        .background {
            Capsule()
                .fill(isLeaning ? tint : Color.clear)
        }
        .overlay {
            Capsule().strokeBorder(tint.opacity(isLeaning ? 0 : 0.55), lineWidth: 2)
        }
        .scaleEffect(isLeaning ? 1.08 : 1)
        .animation(.spring(response: 0.26, dampingFraction: 0.7), value: isLeaning)
    }
}
