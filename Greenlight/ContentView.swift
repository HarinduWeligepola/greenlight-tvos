//
//  ContentView.swift
//  Greenlight
//
//  Root router. The session object owns the phase; this view only decides
//  which screen that phase maps to and how one screen gives way to the next.
//

import SwiftUI

struct ContentView: View {
    @State private var session = SessionViewModel()

    var body: some View {
        ZStack {
            Theme.base.ignoresSafeArea()

            switch session.phase {
            case .lobby:
                LobbyView(session: session)
                    .transition(.opacity)
            case .voting:
                VotingView(session: session)
                    .transition(.opacity)
            case .reveal:
                RevealView(session: session)
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            case .topPicks, .history:
                // Screens land in the next branch.
                Text("Coming soon")
                    .font(Theme.Font.title())
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: session.phase)
        .preferredColorScheme(.dark)
        .task { session.applyLaunchOverrideIfNeeded() }
    }
}

#Preview {
    ContentView()
}
