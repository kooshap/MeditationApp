# App Store listing draft

Copy these into App Store Connect. Character limits are Apple's; counts were checked.

## App information

| Field | Value |
|---|---|
| Name (30) | `Meditate: Minimal Timer` |
| Subtitle (30) | `Quiet bells, fully offline` |
| Primary category | Health & Fitness |
| Secondary category | Lifestyle |
| Privacy Policy URL | https://github.com/kooshap/MeditationApp/blob/main/PRIVACY.md |
| Support URL | https://github.com/kooshap/MeditationApp/blob/main/SUPPORT.md |
| Marketing URL (optional) | https://github.com/kooshap/MeditationApp |
| Copyright | `2026 Koosha Paridel` |

**About the name:** the home-screen name stays "Meditate" (`CFBundleDisplayName`). The App Store name starts with the same word, which keeps the two consistent for App Review (Apple asks that they be similar). Store names must be unique; App Store Connect confirms availability when you create the app record. If it's taken, `Meditate: Simple Bell Timer` is a close fallback.

## Promotional text (170)

```
A quiet timer for sitting practice. Choose how long, pick a bell, and press Start. No accounts, no ads, no tracking — just bells and silence.
```

## Description (4000)

```
Meditate is a timer for sitting practice, and nothing more. Set how long you want to sit, choose a bell, and press Start. The screen goes dark, the countdown begins, and a bell tells you when you're done.

FIVE BELLS
Tibetan singing bowl, Zen temple bowl, crystal bowl, wind chime, and gong. Choose one bell to open your session and another to close it, and tap any bell to hear it first.

MADE FOR SITTING
• Distraction-free countdown on a black screen that stays awake
• The ending bell still rings when your phone is locked
• Pauses automatically if a call comes in
• Remembers your last duration, bells, and volume

PRIVATE BY DESIGN
No account. No ads. No analytics. No internet connection needed. Your settings never leave your device.
```

## Keywords (100)

```
meditation,zen,singing bowl,tibetan,gong,mindfulness,calm,breathe,focus,sit,vipassana,silent,chime
```

Words already in the name and subtitle (meditate, minimal, timer, quiet, bells, offline) are left out — Apple indexes those automatically, so repeating them wastes space. "meditation" is included because Apple doesn't reliably match it to "meditate".

## Screenshots — iPhone 6.9" (1320 × 2868)

Two sets, same order: plain app screens in `AppStore/screenshots/`, or versions with a short caption above each screen in `AppStore/screenshots/captioned/` (recommended — the mostly black screens read better with a line of context). Upload one set:

1. `01-setup.png` — duration picker, bells, volume
2. `02-timer.png` — countdown in progress
3. `03-paused.png` — paused, with Finish and Resume
4. `04-complete.png` — session complete

## App Review notes (4000)

```
No sign-in is required; all features are available on launch.

To test:
1. Choose a short duration (e.g. 0h 0m 10s), pick start and end bells, and tap Start.
2. The app asks whether to enable notifications. Allowing them lets the ending bell ring as a local notification if the screen is locked mid-session.
3. Lock the device during the session; the ending bell arrives as a notification when time is up.

The app is fully offline: no network requests, no analytics, no third-party SDKs. The Privacy Policy link is at the bottom of the main screen. All bell sounds are original, synthesized for this app.
```

## Age rating — draft answers

Every content question is "None" / "No": no violence, sexual content, profanity, alcohol or drugs, gambling or contests, horror, user-generated content, messaging, advertising, or unrestricted web access (the Privacy Policy link opens Safari, not an in-app browser). No parental controls or age verification needed.

**Your call:** the medical/wellness question. The app is a timer with no health guidance or treatment claims, so "No" is defensible; answer "Yes" (infrequent) if you consider meditation itself a wellness topic. Either way the expected rating is **4+**.

## App Privacy — draft answer

**Data Not Collected.** Matches `PRIVACY.md` and `PrivacyInfo.xcprivacy`: settings stay on device in `UserDefaults`, notifications are local, and there are no network calls.
