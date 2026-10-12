//
//  LobbyView.swift
//  Greenlight
//
//  Who is in the room. Two to six seats; each can be renamed and taken in or
//  out of the round. Nothing else happens here — the app should reach the
//  first film in a couple of presses, so focus starts on the start button
//  rather than on the roster.
//

import SwiftUI

struct LobbyView: View {
    @Bindable var session: SessionViewModel

    private enum Field: Hashable { case start }

    @FocusState private var focus: Field?
    /// A slow open of the mark on entry, so the lobby is never fully static.
    @State private var markOpen: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Masthead
            HStack(alignment: .center) {
                GreenlightWordmark(markSize: 124, openAmount: markOpen)
                Spacer()
                Button("Past verdicts") { session.showHistory() }
                    .buttonStyle(.glassPill(tint: Theme.textSecondary))
            }

            Text("Nobody watches until everybody agrees.")
                .font(Theme.Font.body(30))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, Theme.Space.sm)

            Spacer(minLength: Theme.Space.lg)

            // MARK: Roster
            Text("WHO'S IN THE ROOM")
                .font(Theme.Font.label(22))
                .kerning(4)
                .foregroundStyle(Theme.textTertiary)
                .padding(.bottom, Theme.Space.md)

            HStack(spacing: Theme.Space.sm) {
                ForEach(session.roster) { player in
                    SeatCard(
                        player: player,
                        isPlaying: session.activeSeats.contains(player.seat),
                        onToggle: { session.toggleSeat(player.seat) },
                        onRename: { session.rename(seat: player.seat, to: $0) }
                    )
                }
            }

            Spacer(minLength: Theme.Space.lg)

            // MARK: Start
            HStack(spacing: Theme.Space.md) {
                Button {
                    session.start()
                } label: {
                    Label("Start the round", systemImage: "play.fill")
                }
                .buttonStyle(.glassPill(tint: Theme.green, prominent: true))
                .disabled(!session.canStart)
                .focused($focus, equals: .start)

                Text("\(session.players.count) playing  ·  12 films  ·  about 90 seconds")
                    .font(Theme.Font.caption(24))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(.horizontal, 90)
        .padding(.vertical, 70)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .defaultFocus($focus, .start)
        .task {
            withAnimation(.easeInOut(duration: 1.6)) { markOpen = 0.14 }
        }
    }
}

// MARK: - Seat

private struct SeatCard: View {
    let player: Player
    let isPlaying: Bool
    let onToggle: () -> Void
    let onRename: (String) -> Void

    @State private var draftName: String = ""
    /// tvOS draws its own light focus pill behind a text field, so the text
    /// colour has to invert while the field holds focus.
    @FocusState private var isEditingName: Bool

    var body: some View {
        VStack(spacing: Theme.Space.sm) {
            PlayerToken(player: player, size: 92, isActive: isPlaying, hasVoted: isPlaying)
                .opacity(isPlaying ? 1 : 0.45)

            TextField("Name", text: $draftName)
                .textFieldStyle(.plain)
                .font(Theme.Font.caption(24))
                .foregroundStyle(isEditingName ? Theme.base : Theme.textPrimary)
                .multilineTextAlignment(.center)
                .focused($isEditingName)
                .padding(.vertical, 10)
                .padding(.horizontal, Theme.Space.xs)
                .background {
                    Capsule().strokeBorder(
                        isEditingName ? Color.clear : Theme.hairline,
                        lineWidth: 1.5
                    )
                }
                .onSubmit { onRename(draftName) }
                .onChange(of: isEditingName) { _, editing in
                    if !editing { onRename(draftName) }
                }

            Button(action: onToggle) {
                Text(isPlaying ? "Playing" : "Sitting out")
                    .font(Theme.Font.label(20))
            }
            .buttonStyle(SeatToggleStyle(tint: isPlaying ? player.colour : Theme.hairline, isOn: isPlaying))
        }
        .padding(Theme.Space.sm)
        .frame(width: 252)
        .glassPanel()
        .opacity(isPlaying ? 1 : 0.72)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPlaying)
        .onAppear { draftName = player.name }
    }
}

/// The in/out control on a seat. Small, so it carries an explicit focus rim
/// rather than relying on scale alone to show where the cursor is.
private struct SeatToggleStyle: ButtonStyle {
    let tint: Color
    let isOn: Bool

    func makeBody(configuration: Configuration) -> some View {
        StyleBody(configuration: configuration, tint: tint, isOn: isOn)
    }

    private struct StyleBody: View {
        let configuration: Configuration
        let tint: Color
        let isOn: Bool

        @Environment(\.isFocused) private var isFocused

        var body: some View {
            configuration.label
                .foregroundStyle(isOn ? Theme.base : Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background { Capsule().fill(tint) }
                .overlay {
                    Capsule().strokeBorder(
                        isFocused ? Theme.textPrimary : Color.clear,
                        lineWidth: 3
                    )
                }
                .scaleEffect(configuration.isPressed ? 0.95 : (isFocused ? 1.05 : 1))
                .animation(.spring(response: 0.26, dampingFraction: 0.72), value: isFocused)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }
}
