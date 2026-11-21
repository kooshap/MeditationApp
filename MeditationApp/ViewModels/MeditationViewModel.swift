import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class MeditationViewModel {

    enum AppScreen: Equatable { case setup, activeTimer, sessionComplete }
    enum TimerState: Equatable { case idle, running, paused }

    // MARK: — State
    var screen: AppScreen      = .setup
    var timerState: TimerState = .idle
    var remaining: TimeInterval = 0
    private(set) var practice  = PracticeLog.load()

    var settings: SessionSettings {
        didSet {
            settings.save()
            audio.updateVolume(settings.volume)
        }
    }

    // MARK: — Private
    private var sessionEndDate: Date?
    private var sessionDuration: TimeInterval = 0
    private var timer: Timer?
    private let audio = AudioEngine()

    init() {
        settings = SessionSettings.load()
        audio.configure()
        observeForeground()
    }

    // MARK: — Session control

    func start() {
        let duration = TimeInterval(settings.totalSeconds)
        sessionDuration = duration
        remaining  = duration
        timerState = .running
        screen     = .activeTimer
        audio.play(settings.bell, volume: settings.volume)

        // Delay countdown until the screen transition finishes (0.55s in ContentView)
        // so the first second is never visually clipped
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            sessionEndDate = Date().addingTimeInterval(remaining)
            scheduleTimer()
        }
    }

    func pause() {
        guard timerState == .running else { return }
        syncRemainingToClock()
        // The clock may say the session already ended, in which case it just completed
        guard timerState == .running else { return }
        sessionEndDate = nil
        timerState     = .paused
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard timerState == .paused else { return }
        sessionEndDate = Date().addingTimeInterval(remaining)
        timerState     = .running
        scheduleTimer()
    }

    func finish() {
        // Ending early still counts toward the streak once a full minute has been sat
        if sessionDuration - remaining >= 60 { practice.record() }
        cleanup()
        screen = .setup
    }

    func dismissComplete() {
        screen = .setup
    }

    func previewBell(_ bell: Bell) {
        audio.play(bell, volume: settings.volume)
    }

    // MARK: — Private

    // Derive remaining from the end date rather than counting ticks, so a stalled or
    // suspended app can never freeze the countdown. The timer fires 0–1s after each
    // whole second since sessionEndDate was set, so ceil() lands on exactly one value
    // per tick — no half-second flicker.
    private func syncRemainingToClock() {
        guard let end = sessionEndDate else { return }
        remaining = max(ceil(end.timeIntervalSinceNow), 0)
        if remaining == 0 { complete() }
    }

    private func complete() {
        practice.record()
        cleanup()
        audio.play(settings.bell, volume: settings.volume)
        screen = .sessionComplete
    }

    private func cleanup() {
        timer?.invalidate()
        timer          = nil
        timerState     = .idle
        sessionEndDate = nil
    }

    private func scheduleTimer() {
        // Scheduled on the main run loop, so the callback is already on the main actor
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.syncRemainingToClock() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    // Audio interruptions deliberately don't pause the session: the app plays no continuous
    // audio, and iOS deactivates the session on suspension, which used to freeze the timer.

    // Update the display right away after returning from background instead of waiting
    // for the next tick. If the session ended while away, this completes it and rings the bell.
    private func observeForeground() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.timerState == .running else { return }
                self.syncRemainingToClock()
            }
        }
    }
}
