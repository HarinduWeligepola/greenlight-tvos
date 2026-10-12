//
//  HistoryView.swift
//  Greenlight
//
//  Everything the household has agreed on, read straight out of SwiftData.
//
//  Rows are deliberately not focusable. There is nothing to open and nothing
//  to edit here, and making a row pressable would put a destructive action
//  under the one button people press by reflex. Clearing the log is a single
//  explicit control with a confirmation.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Bindable var session: SessionViewModel

    @Environment(\.modelContext) private var context
    @Query(sort: \Verdict.decidedAt, order: .reverse) private var verdicts: [Verdict]

    @State private var isConfirmingClear = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, Theme.Space.md)

            if verdicts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Space.sm) {
                        ForEach(verdicts) { verdict in
                            VerdictRow(verdict: verdict)
                        }
                    }
                    .padding(.vertical, Theme.Space.xs)
                }
                .scrollClipDisabled()
            }
        }
        .padding(.horizontal, 90)
        .padding(.vertical, 70)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onExitCommand { session.dismissHistory() }
        .alert("Clear every verdict?", isPresented: $isConfirmingClear) {
            Button("Clear", role: .destructive, action: clearAll)
            Button("Keep them", role: .cancel) { }
        } message: {
            Text("This removes all \(verdicts.count) saved nights. It cannot be undone.")
        }
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Past verdicts")
                    .font(Theme.Font.display(76))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(Theme.Font.body(28))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            HStack(spacing: Theme.Space.sm) {
                if !verdicts.isEmpty {
                    Button("Clear all") { isConfirmingClear = true }
                        .buttonStyle(.glassPill(tint: Theme.pass))
                }
                Button("Back") { session.dismissHistory() }
                    .buttonStyle(.glassPill(tint: Theme.textSecondary))
            }
        }
    }

    private var subtitle: String {
        verdicts.isEmpty
            ? "Nothing agreed yet."
            : "\(verdicts.count) \(verdicts.count == 1 ? "night" : "nights") settled."
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Space.md) {
            ApertureMark(openAmount: 0, intensity: 0.4)
                .frame(width: 160, height: 160)
                .opacity(0.5)
            Text("Your first greenlit film will appear here.")
                .font(Theme.Font.body(30))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func clearAll() {
        for verdict in verdicts { context.delete(verdict) }
        try? context.save()
    }
}

// MARK: - Row

private struct VerdictRow: View {
    let verdict: Verdict

    var body: some View {
        HStack(spacing: Theme.Space.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: UInt32(verdict.filmTintHex)).opacity(0.35))
                Image(systemName: verdict.filmMotif)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Theme.textPrimary.opacity(0.85))
            }
            .frame(width: 104, height: 104)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: Theme.Space.xs) {
                    Text(verdict.filmTitle)
                        .font(Theme.Font.headline(36))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    agreementBadge
                }
                Text(detailLine)
                    .font(Theme.Font.caption(24))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: Theme.Space.md)

            VStack(alignment: .trailing, spacing: 12) {
                PlayerDotCluster(seats: verdict.playerSeats)
                Text(verdict.decidedAt.formatted(.dateTime.day().month(.abbreviated).hour().minute()))
                    .font(Theme.Font.caption(22))
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
            }
            .frame(width: 280, alignment: .trailing)
        }
        .padding(Theme.Space.sm)
        .frame(maxWidth: .infinity)
        .glassPanel()
    }

    /// A clean sweep earns the signal green. A film the room merely settled
    /// on does not, which is the palette rule holding even in the log.
    @ViewBuilder
    private var agreementBadge: some View {
        let unanimous = verdict.isUnanimous
        Text(unanimous ? "Unanimous" : "\(verdict.yesVotes) of \(verdict.totalVotes)")
            .font(Theme.Font.label(18))
            .foregroundStyle(unanimous ? Theme.green : Theme.textTertiary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background {
                Capsule().strokeBorder(
                    unanimous ? Theme.green.opacity(0.55) : Theme.hairline,
                    lineWidth: 1.5
                )
            }
    }

    private var detailLine: String {
        let films = verdict.filmsConsidered
        let suffix = verdict.isUnanimous
            ? "agreed after \(films) \(films == 1 ? "film" : "films")"
            : "settled after \(films) \(films == 1 ? "film" : "films")"
        return "\(verdict.filmYear)  ·  \(verdict.filmGenre)  ·  \(suffix)"
    }
}
