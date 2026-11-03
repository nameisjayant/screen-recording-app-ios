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
- Home hosts a custom game-style bottom bar (`HomeBottomBar`): Dashboard and Settings tabs, plus a raised microphone button that opens the recording setup dialog (face camera / microphone toggles, remembered in `AppPreferences`).
- Recording: see [Recording](#recording).
- Theme: `AppearanceStore` (owned by `AppContainer`) holds the System / Light / Dark choice, persisted in `AppPreferences` and picked in Settings. Dark is the default.

```
Screen Recorder/
  App/            entry point, RootView, AppRouter, AppContainer
  Core/           architecture contract, environment, storage, Recording (controller, broadcast picker, face cam)
  Common/         shared UI: Theme (Palette, Typography, Metrics), Components, Extensions
  Features/       Splash, Onboarding, Home, Dashboard, Recorder, Settings
  Resources/      Assets, Fonts, Localizable.xcstrings
Shared/
  RecordingSession/  RecordingStatus + RecordingChannel (app, broadcast and widget targets)
  LiveActivity/      Live Activity attributes + pause/resume/stop intents (app and widget targets)
RecQuestBroadcast/   Broadcast Upload Extension: records the screen, app audio and mic to MP4
RecQuestWidgets/     Widget extension: the recording Live Activity (Lock Screen + Dynamic Island)
Config/              xcconfigs, Info.plists, AppGroup.entitlements
scripts/             generate_app_icon.swift
```

## Recording

- **Start**: "Start Recording" in the setup dialog opens the iOS broadcast sheet with RecQuest preselected; the recording begins after the user taps *Start Broadcast* (iOS requires this confirmation).
- **Engine**: `RecQuestBroadcast` runs in its own process, so recording continues with RecQuest in the background or closed. It writes `RecQuest <date>.mp4` to `Recordings/` in the App Group container (`group.<bundle id>`, per flavor). Video H.264 plus AAC tracks for app audio and (if enabled) microphone; paused time is cut out.
- **Controls**: a Live Activity (Lock Screen / Dynamic Island) with Pause/Resume and Stop, plus a status bar above the Home bottom bar. Buttons are `LiveActivityIntent`s that run in the app process and message the extension.
- **IPC**: `RecordingChannel` holds `RecordingStatus` in the shared App Group defaults and pings the other side with Darwin notifications. The extension writes a heartbeat every 2s; a stale heartbeat counts as stopped.
- **Storage & Dashboard**: the extension can only write to the App Group, so `FileRecordingLibrary` moves finished files into `Documents/Recordings` whenever the Dashboard loads (on appear, on return to the app, and when a recording ends). That folder shows in the Files app under On My iPhone › RecQuest (`UIFileSharingEnabled`). The Dashboard lists recordings newest first with thumbnail, date, length and size. Tap one to play it; the menu has Share, Save to Photos and Delete (with confirmation).
- **Microphone**: the extension keeps mic audio only when enabled in RecQuest *and* switched on in the iOS broadcast sheet.
- **Face cam**: extensions can't use the camera, so the face cam is an on-screen bubble (`FaceCamController`, `LiveFaceCamBubble`) that the recording captures. Outside RecQuest it moves to Picture in Picture (`UIBackgroundModes: audio`). The camera only keeps streaming in the background where iOS allows multitasking camera access; otherwise the bubble holds its last frame.
- Broadcasts don't run in the Simulator; test on a device.

## Design

- Fonts: **Fredoka** (display, buttons) and **Nunito** (body), both SIL OFL.
- Palette "Arcade Pop": deep navy with violet, record red, sun yellow and mint; chunky 3D buttons (`.buttonStyle(.game(...))`).
- Light and dark: surface and text colors in `Palette` adapt via `Color(light:dark:)`; brand colors stay the same. Use `Palette` tokens instead of hardcoded colors so both themes work.
- The app icon is drawn in code. Regenerate it with `swift scripts/generate_app_icon.swift` from the repo root.

## Tests

- Unit tests (Swift Testing): view models (Home, Dashboard, Settings, …), router and `RecordingStatus` timing.
- UI tests launch with `--ui-testing`, so preferences are kept in memory and onboarding always shows.
