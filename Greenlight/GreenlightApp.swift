//
//  GreenlightApp.swift
//  Greenlight
//
//  A tvOS prototype for settling what a room watches together.
//

import SwiftUI
import SwiftData

@main
struct GreenlightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Verdict.self)
    }
}
