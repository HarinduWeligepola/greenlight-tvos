# Greenlight

**Nobody watches until everybody agrees.**

A tvOS prototype that settles what a room watches together, in about ninety
seconds. One remote goes round the sofa, each person votes in secret on the
film currently on screen, and the moment a film takes a yes from *everybody*
the screen floods green.

Built for SE4041 Mobile Application Design and Development, Assignment 02
Part B (innovative application for VisionOS or tvOS).

---

## The idea

Choosing is the worst part of a shared streaming night. Everybody scrolls,
nobody commits, and the group picks by attrition rather than by agreement.
Greenlight turns that into a short game with an unambiguous end state.

The name is the mechanic: in the film industry a project is *greenlit* when
everyone in the room approves it.

## Existing apps that are similar

Two kinds of product already work on the "what do we watch?" problem. Group
matching apps let a group agree, but each person needs their own device. TV
guides run on the television, but they recommend for one viewer and have no
way for a room to reach agreement.

| Product | What it does | Where it runs | How a group decides |
|---|---|---|---|
| **Swyf Together** | Group members pick genres and services, then swipe on films; a film matches when everyone swipes right | iPhone (also listed for Mac and Vision Pro) | Unanimous match, one device per person |
| **MovieMatch** | Self-hosted service that deals films from a Plex library; people swipe +1 / −1 and films liked by two or more appear as matches | Browser, against your own Plex server | Majority match, one device per person, needs Plex |
| **Likewise** | Personal recommendations for films, TV and books, with watch lists and friends' suggestions | Phone, plus TV apps for Apple TV, Android TV and Fire TV | None; recommendations are per person |
| **Reelgood** | One guide across all streaming subscriptions, with tracking and new-episode alerts | Web, iOS, Android, Android TV | None; single user |
| **Flickmetrix** | Combines Rotten Tomatoes, IMDb, Letterboxd and Metacritic scores, with filters, to find highly rated films on Netflix and Prime | Web | None; one person searches for the group |
| **Netflix "Play Something"** | A shuffle button that started a title for you; withdrawn by Netflix in 2023 | Netflix apps, including TVs | None; chooses for you rather than asking the room |

**Where Greenlight fits.** It combines the two halves. It keeps the unanimous
"everybody said yes" rule that makes Swyf Together satisfying, but moves it
onto the television, where the decision is actually made, using the one remote
already on the coffee table. Nobody needs an account, a phone, or a server.
Votes are secret, so the loudest person on the sofa cannot steer the room, and
if nothing is unanimous the room still leaves with its best-supported film
instead of starting again. Netflix's withdrawal of "Play Something" is a useful
signal: a TV feature that decides *for* a group was not enough, which is the
gap a TV feature that lets the group decide *together* is aimed at.

---

## Requirements

| | |
|---|---|
| Xcode | 26.0 or later |
| tvOS SDK | 26.0 or later |
| Target | Apple TV, tvOS 26.1 |
| Language | Swift 5, SwiftUI |

## Build and run

```bash
open Greenlight.xcodeproj
```

Choose the **Greenlight** scheme and any **Apple TV** simulator running
tvOS 26.1, then run. There are no package dependencies and nothing to
configure.

From the command line:

```bash
xcodebuild -project Greenlight.xcodeproj -scheme Greenlight \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.1' \
  build
```

## How to play

1. **Lobby** — two to six seats. Press a seat's pill to take that person in
   or out of the round; select the name field to rename them.
2. **Start the round** — twelve films are dealt at random.
3. **Voting** — the remote passes round the room. For each film, every player
   takes a turn:
   - **swipe left** on the Siri Remote touch surface to pass
   - **swipe right** to greenlight
   In the simulator these are the **left** and **right arrow keys**.
   Votes show only as a filled token in the player's colour, never as yes or
   no, so the room cannot read how it is leaning.
4. **Greenlit** — a film that takes a yes from everyone ends the round with
   the green flood, alongside the films that were also in the running. The
   verdict is saved.
5. **No clean sweep** — if the deck runs out with nothing unanimous, the room
   is not sent away empty handed. Every film it saw is ranked by how much of
   the room approved, the leader is presented in full, and the room can
   settle on it in one press.
6. **Past verdicts** — every agreed film, persisted across launches and
   badged as either unanimous or settled.

Press **Menu** at any point to back out of the current screen.

---

## Architecture

MVVM, with all game rules in a single observable model and no logic in the
views.

```
Greenlight/
├── GreenlightApp.swift          App entry; installs the SwiftData container
├── ContentView.swift            Root router; maps session phase to a screen
├── DesignSystem/
│   ├── Theme.swift              Colour, type scale, spacing
│   ├── LiquidGlass.swift        Custom glass modifiers (see below)
│   └── ApertureMark.swift       The brand mark, drawn as animatable vector geometry
├── Models/
│   ├── Film.swift               Value type for a candidate film
│   ├── FilmTally.swift          What the room thought of one film
│   ├── Player.swift             A seat at the table
│   ├── Verdict.swift            @Model — the persisted record of an agreement
│   └── FilmCatalog.swift        Seed catalogue and deck dealing
├── ViewModels/
│   └── SessionViewModel.swift   @Observable — roster, deck, votes, phase, rules
└── Views/
    ├── LobbyView.swift
    ├── VotingView.swift
    ├── RevealView.swift
    ├── TopPicksView.swift
    ├── HistoryView.swift
    └── Components/
        ├── FilmPosterView.swift
        ├── PlayerViews.swift
        └── GlassButton.swift
```

### Platform-specific work

- **Liquid Glass.** `GlassPanelModifier`, `GlassCardModifier` and
  `GlassActionModifier` wrap the system material in one vocabulary, with an
  `#available` fallback to `.ultraThinMaterial`. The greenlight control uses
  a genuinely tinted, interactive glass so it refracts green.
- **The focus engine.** Focus is always shown as lift, scale and an off-white
  rim — never green — so "where the cursor is" can never be confused with
  "this is approved". `GlassButtonStyle` reads `\.isFocused` from the
  environment, and picks its label colour from the tint's luminance so a new
  tint can never ship an unreadable button.
- **Direct remote input.** The voting screen is a single focusable surface
  driven by `onMoveCommand`, so a vote is one swipe with nothing to aim at.
  That is what makes the remote comfortable to hand around a sofa.
- **Layered app icon and Top Shelf image**, built from the brand mark.
- **SwiftData** for verdict history.

### Design system

Dark only, by design. tvOS does offer a light appearance, but the app sets
`.preferredColorScheme(.dark)`: it is used in a dim living room, and the green
reveal only lands against a dark screen.

| Token | Hex | Use |
|---|---|---|
| `surface/base` | `#0A0B0C` | Screen background |
| `surface/card` | `#14161A` | Resting card |
| `surface/focused` | `#1E2228` | Focused card |
| `stroke/hairline` | `#2A2F36` | Borders |
| `text/primary` | `#F4F6F5` | Titles |
| `text/secondary` | `#A8B0AE` | Metadata |
| `text/tertiary` | `#6B7370` | Hints |
| `signal/green` | `#2BE06B` | Approval only |
| `signal/pass` | `#4E565E` | Pass |
| `player/1…6` | amber → cyan | Player identity |

Three rules govern the palette:

1. **Green means unanimous approval and nothing else.** It is never used for
   navigation, focus or decoration, which is why the reveal lands. A film the
   room merely *settled* on gets the same screen in neutral tone with the
   aperture only part open — the palette is not allowed to overstate what the
   room actually agreed.
2. **Pass is a dim slate, not red.** Saturated red blooms on TV panels, and
   declining a film should not feel like an error.
3. **The six player accents sweep the spectrum but skip green**, so no
   player colour can be mistaken for a verdict.

---

## Content and assets

No third-party artwork ships with this prototype. Film posters are generated
at runtime from an SF Symbol motif and a tint, loglines were written for this
project, and the brand mark is drawn in SwiftUI as vector geometry rather
than bundled as a bitmap — which is also what lets the aperture animate open
on the reveal.

`FilmCatalog` is deliberately shaped like the response a real catalogue feed
would return, keyed to the services a household subscribes to.

---

## Testing

Each screen can be launched directly for inspection:

```bash
xcrun simctl launch <device> lk.ac.sliit.Greenlight -glDemoPhase voting
```

Accepted values are `voting`, `reveal`, `toppicks` and `history`. The flag
is read once at launch and has no effect on a normal run.

**Not yet covered:** there is no test target. The obvious first additions are
unit tests over `SessionViewModel` (unanimity, the ranking and its tie-break,
rotation of the voting order, the two-player floor, deck exhaustion) and an
`XCUIRemote` UI test that drives a full round.

---

### Ranking

Every film that goes round the table leaves a `FilmTally` behind, so a
rejected film is information rather than waste. `rankedPicks` orders them by
approval, breaking ties towards the film the room saw first so an early
favourite is not demoted by a later tie. That single list drives both the
"also in the running" strip on a successful reveal and the whole No clean
sweep screen.

## Known limitations

- The catalogue is a local seed of sixteen films rather than a live feed.
- The app icon's parallax layers are a flat front plate over a background
  plate; separating the ring and blades into their own layers would give the
  icon real depth on focus.
- Multi-user means several people sharing one remote. A future version would
  let each person vote from their own phone over the local network, which is
  what the vote model is already structured for.
