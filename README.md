# RecQuest

A simple iOS screen recorder (screen recording, face cam, commentary) with a playful, game-style UI.

## Flavors

| Scheme | Configs | Bundle ID | Name | Icon |
| --- | --- | --- | --- | --- |
| RecQuest Beta | Debug-Beta / Release-Beta | `com.nameisjayant.Screen-Recorder.beta` | RecQuest β | `AppIcon-Beta` |
| RecQuest Prod | Debug-Prod / Release-Prod | `com.nameisjayant.Screen-Recorder` | RecQuest | `AppIcon` |

Flavor settings live in `Config/*.xcconfig` (keep them out of the target's build settings in Xcode).
Code can branch with `AppEnvironment.current` (compile conditions `BETA` / `PROD`).

## Architecture

SwiftUI + MVI (Swift 6, main-actor by default, iOS 17+).

- Each feature has `View/`, `ViewModel/`, `Components/` (feature-only views) and optional `Models/`.
- View models conform to `ViewModel`: they expose an `Equatable` `state` and take user actions via `send(_ intent:)`.
- `AppContainer` is the composition root that builds view models and owns dependencies.
- `AppRouter` drives the top-level flow: Splash → Onboarding (first launch) → Home.

```
Screen Recorder/
  App/            entry point, RootView, AppRouter, AppContainer
  Core/           architecture contract, environment, storage
  Common/         shared UI: Theme (Palette, Typography, Metrics), Components, Extensions
  Features/       Splash, Onboarding, Home
  Resources/      Assets, Fonts, Localizable.xcstrings
Config/           xcconfigs + Info.plist
scripts/          generate_app_icon.swift
```

## Design

- Fonts: **Fredoka** (display, buttons) and **Nunito** (body), both SIL OFL.
- Palette "Arcade Pop": deep navy with violet, record red, sun yellow and mint; chunky 3D buttons (`.buttonStyle(.game(...))`).
- The app icon is drawn in code. Regenerate it with `swift scripts/generate_app_icon.swift` from the repo root.

## Tests

- Unit tests (Swift Testing): view models and router.
- UI tests launch with `--ui-testing`, so preferences are kept in memory and onboarding always shows.
