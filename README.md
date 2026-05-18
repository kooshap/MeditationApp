# MeditationApp

A minimalist, fully offline meditation timer for iOS. No accounts, no network, no data collection.

## Requirements

- Xcode 16+
- iOS 17+ deployment target
- [XcodeGen](https://github.com/yonatanKreiner/XcodeGen) to generate the `.xcodeproj`

## Setup

```bash
# Install XcodeGen if needed
brew install xcodegen

# Generate the Xcode project
cd /path/to/MeditationApp
xcodegen generate

# Open in Xcode
open MeditationApp.xcodeproj
```

## Audio Assets

Drop MP3 files into `MeditationApp/Resources/` before building:

| Filename        | Bell        |
|-----------------|-------------|
| `tibetan.mp3`   | Tibetan     |
| `zen_bowl.mp3`  | Zen Bowl    |
| `crystal.mp3`   | Crystal     |
| `chime.mp3`     | Chime       |
| `gong.mp3`      | Gong        |

Free sources: [freesound.org](https://freesound.org) · [zapsplat.com](https://zapsplat.com)  
Keep files short (~2–5s) and under 200 KB each.

## Architecture

```
MeditationApp/
├── Models/
│   ├── Bell.swift              — Bell enum (name, icon, filename)
│   └── SessionSettings.swift  — Codable settings, UserDefaults persistence
├── ViewModels/
│   └── MeditationViewModel.swift  — @Observable state machine; handles timer, audio, interruptions
├── Services/
│   ├── AudioEngine.swift          — AVAudioPlayer wrapper, AVAudioSession config
│   └── BackgroundTimerService.swift — UNUserNotificationCenter fallback bell
└── Views/
    ├── SetupView.swift            — Duration picker, bell carousel, volume, start button
    ├── ActiveTimerView.swift      — Distraction-free dark countdown; disables auto-lock
    ├── SessionCompleteView.swift  — Post-session screen; tap anywhere to dismiss
    ├── Components/
    │   ├── DurationWheelPicker.swift  — UIPickerView (UIViewRepresentable) with haptics
    │   ├── BellCarousel.swift         — Horizontal bell selector with instant audio preview
    │   ├── SettingsSummary.swift      — Summary row (duration, start/end bell)
    │   └── VolumeSliderView.swift
    └── Styles/
        └── ButtonStyles.swift     — StartButtonStyle, TimerControlStyle
```

## OS-Level Features

| Feature | Implementation |
|---|---|
| Background timer bell | `UNUserNotificationCenter` scheduled at session start; cancelled on manual finish |
| Lock-screen bell | Same local notification — fires even when screen is locked |
| Auto-lock prevention | `UIApplication.shared.isIdleTimerDisabled` toggled in `ActiveTimerView` |
| Audio interruption pause | `AVAudioSession.interruptionNotification` observer in ViewModel |
| Foreground reconciliation | `UIApplication.willEnterForegroundNotification` re-checks clock on return |
| Offline | Zero network calls; all assets bundled |
| Persistence | `UserDefaults` — last duration, start/end bell, volume restored on launch |
