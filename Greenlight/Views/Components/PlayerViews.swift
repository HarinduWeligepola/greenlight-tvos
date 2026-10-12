//
//  PlayerViews.swift
//  Greenlight
//
//  Small shared pieces that show who is in the room and how far the current
//  round has got. Votes are shown as filled dots in each player's colour and
//  never as yes or no, so nobody can see how the room is leaning before the
//  verdict lands.
//

import SwiftUI

/// A single player's token.
struct PlayerToken: View {
    let player: Player
    var size: CGFloat = 76
    var isActive: Bool = false
    var hasVoted: Bool = false

    private var tagScale: CGFloat {
        switch player.tag.count {
        case 1: return 0.42
        case 2: return 0.34
        default: return 0.27
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(hasVoted || isActive ? player.colour : player.colour.opacity(0.18))
            Circle()
                .strokeBorder(player.colour.opacity(isActive ? 1 : 0.5), lineWidth: isActive ? 4 : 2)

            Text(player.tag)
                .font(.system(size: size * tagScale, weight: .bold, design: .rounded))
                .foregroundStyle(hasVoted || isActive ? Theme.base : player.colour)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.horizontal, size * 0.1)
        }
        .frame(width: size, height: size)
        .scaleEffect(isActive ? 1.14 : 1.0)
        .shadow(color: player.colour.opacity(isActive ? 0.55 : 0), radius: 22)
        .animation(.spring(response: 0.34, dampingFraction: 0.7), value: isActive)
        .animation(.spring(response: 0.34, dampingFraction: 0.7), value: hasVoted)
    }
}

/// The row of tokens along the top of the voting screen.
struct VoteProgressRail: View {
    let order: [Player]
    let votesCast: Int

    var body: some View {
        HStack(spacing: Theme.Space.sm) {
            ForEach(Array(order.enumerated()), id: \.element.id) { index, player in
                VStack(spacing: 10) {
                    PlayerToken(
                        player: player,
                        size: 72,
                        isActive: index == votesCast,
                        hasVoted: index < votesCast
                    )
                    Text(player.name)
                        .font(Theme.Font.caption(20))
                        .foregroundStyle(
                            index == votesCast ? Theme.textPrimary : Theme.textTertiary
                        )
                        .lineLimit(1)
                }
                .frame(width: 128)
            }
        }
    }
}

/// Compact stack of player dots, used on history rows.
struct PlayerDotCluster: View {
    let seats: [Int]
    var size: CGFloat = 26

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(seats.enumerated()), id: \.offset) { _, seat in
                Circle()
                    .fill(Theme.playerColor(seat))
                    .frame(width: size, height: size)
            }
        }
    }
}
