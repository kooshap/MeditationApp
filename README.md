# MeditationApp

A minimalist, fully offline meditation timer for iOS. No accounts, no network, no data collection.

## Requirements

- Xcode 16+
- iOS 17+ deployment target

## Setup

```bash
git clone <repo-url>
open MeditationApp.xcodeproj
```

## Audio Assets

The bell sounds in `MeditationApp/Resources/` are synthesized, not recorded. [`scripts/generate_bells.py`](scripts/generate_bells.py) builds each one from decaying sine partials tuned to the real instrument, plus a short noise burst for the mallet strike. The MP3s are committed, so the project builds straight from a fresh clone.

| Filename       | Bell     | Character                                              |
|----------------|----------|--------------------------------------------------------|
| `tibetan.mp3`  | Tibetan  | Low, warm singing bowl with a slow wobble (8s)         |
| `zen_bowl.mp3` | Zen Bowl | Higher, clear temple bowl with a crisp strike (8s)     |
| `crystal.mp3`  | Crystal  | Near-pure quartz bowl tone, soft attack (7s)           |
| `chime.mp3`    | Chime    | Three tuned tubes struck in quick succession (5s)      |
| `gong.mp3`     | Gong     | Deep boom with a shimmer that swells in (9s)           |

To tweak a bell, edit its function in the script and regenerate. Output is deterministic, so unchanged bells come out identical:

```bash
pip install numpy lameenc
python3 scripts/generate_bells.py
```

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

## License

Code is released under the [MIT License](LICENSE). The bell sounds in `MeditationApp/Resources/` are dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) — use them anywhere, no attribution required.
