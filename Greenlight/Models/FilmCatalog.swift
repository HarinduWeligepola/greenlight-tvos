//
//  FilmCatalog.swift
//  Greenlight
//
//  Seed catalogue for the prototype. In production this would be a remote
//  feed keyed to the services the household actually subscribes to; the
//  shape of `Film` is deliberately the shape such a feed would return.
//
//  Loglines are written for this prototype rather than taken from marketing
//  copy, and artwork is generated at runtime, so nothing here is third party.
//

import Foundation

enum FilmCatalog {

    static let all: [Film] = [
        Film(title: "Arrival", year: 2016, runtime: 116, genre: "Science fiction",
             logline: "A linguist is asked to speak with something that does not experience time the way we do.",
             motif: "waveform.circle", tintHex: 0x5B8DEF),

        Film(title: "The Grand Budapest Hotel", year: 2014, runtime: 99, genre: "Comedy",
             logline: "A concierge and a lobby boy inherit a painting, a fortune and a great deal of trouble.",
             motif: "building.columns", tintHex: 0xF2567E),

        Film(title: "Mad Max: Fury Road", year: 2015, runtime: 120, genre: "Action",
             logline: "Two hours of desert chase, told almost entirely without exposition.",
             motif: "flame", tintHex: 0xFF6F59),

        Film(title: "Spirited Away", year: 2001, runtime: 125, genre: "Animation",
             logline: "A girl takes a job in a bathhouse for spirits to win back her parents.",
             motif: "wind", tintHex: 0x35C6E8),

        Film(title: "Parasite", year: 2019, runtime: 132, genre: "Thriller",
             logline: "One family talks its way into another family's house, one job at a time.",
             motif: "stairs", tintHex: 0xA77BFF),

        Film(title: "Paddington 2", year: 2017, runtime: 103, genre: "Family",
             logline: "A bear is wrongly imprisoned and immediately improves the prison.",
             motif: "teddybear", tintHex: 0xF5A623),

        Film(title: "Blade Runner 2049", year: 2017, runtime: 164, genre: "Science fiction",
             logline: "A detective who already knows what he is goes looking for what he isn't.",
             motif: "cloud.rain", tintHex: 0x5B8DEF),

        Film(title: "Knives Out", year: 2019, runtime: 130, genre: "Mystery",
             logline: "A wealthy novelist dies and every single relative had a reason.",
             motif: "magnifyingglass", tintHex: 0xF2567E),

        Film(title: "Whiplash", year: 2014, runtime: 106, genre: "Drama",
             logline: "A drummer and a teacher discover how far each will go to be proved right.",
             motif: "metronome", tintHex: 0xFF6F59),

        Film(title: "Everything Everywhere All at Once", year: 2022, runtime: 139, genre: "Science fiction",
             logline: "A laundrette owner is audited, and then asked to save every version of herself.",
             motif: "circle.hexagongrid", tintHex: 0xA77BFF),

        Film(title: "Spider-Man: Into the Spider-Verse", year: 2018, runtime: 117, genre: "Animation",
             logline: "A teenager learns the job from five people who already have it.",
             motif: "scribble.variable", tintHex: 0xF2567E),

        Film(title: "The Social Network", year: 2010, runtime: 120, genre: "Drama",
             logline: "A website is built in a dorm room and litigated for the next decade.",
             motif: "laptopcomputer", tintHex: 0x35C6E8),

        Film(title: "Dune", year: 2021, runtime: 155, genre: "Science fiction",
             logline: "A family is handed a desert planet, and the planet declines to be handed over.",
             motif: "sun.max", tintHex: 0xF5A623),

        Film(title: "Jaws", year: 1975, runtime: 124, genre: "Thriller",
             logline: "A beach town refuses to close for the summer, with predictable results.",
             motif: "water.waves", tintHex: 0x5B8DEF),

        Film(title: "Coco", year: 2017, runtime: 105, genre: "Animation",
             logline: "A boy crosses into the land of the dead to ask his family for permission.",
             motif: "guitars", tintHex: 0xF5A623),

        Film(title: "Heat", year: 1995, runtime: 170, genre: "Crime",
             logline: "A detective and a thief recognise each other across a coffee table.",
             motif: "building.2", tintHex: 0x4E565E)
    ]

    /// A shuffled deck for one session.
    static func deck(count: Int = 12) -> [Film] {
        Array(all.shuffled().prefix(min(count, all.count)))
    }
}
