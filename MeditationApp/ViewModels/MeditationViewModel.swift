import Foundation
import Observation
import AVFoundation
import UIKit
import UserNotifications

@Observable
@MainActor
final class MeditationViewModel {

    enum AppScreen: Equatable { case setup, activeTimer, sessionComplete }
    enum TimerState: Equatable { case idle, running, paused }

    // MARK: — State
    var screen: AppScreen      = .setup
    var timerState: TimerState = .idle
    var remaining: TimeInterval = 0
    var showPermissionPrompt   = false

    var settings: SessionSettings {
        didSet { settings.save() }
    }

    // MARK: — Private
    private var sessionEndDate: Date?
    private var timer: Timer?
    private let audio      = AudioEngine()
    private let background = BackgroundTimerService()

    init() {
        settings = SessionSettings.load()
        audio.configure()
        observeInterruptions()
        observeForeground()
    }

    // MARK: — Session control

    // Entry point from the Start button — checks notification permission first
    func requestStart() {
        Task {
            let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            if status == .notDetermined {
                showPermissionPrompt = true
            } else {
                startSession()
            }
        }
    }

    // Called when user taps "Allow" in the permission prompt
    func allowNotificationsAndStart() {
        Task {
            try? await UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert])
            startSession()
        }
    }

    // Called when user taps "Not Now" — timer still works, bell won't fire when locked
    func skipNotificationsAndStart() {
        startSession()
    }

    func pause() {
        guard timerState == .running else { return }
        remaining      = max(sessionEndDate?.timeIntervalSinceNow ?? remaining, 0)
        sessionEndDate = nil
        timerState     = .paused
        timer?.invalidate()
        timer = nil
        background.cancel()
    }

    func resume() {
        guard timerState == .paused else { return }
        sessionEndDate = Date().addingTimeInterval(remaining)
        timerState     = .running
        background.scheduleEnd(after: remaining, bell: settings.endBell)
        scheduleTimer()
    }

    func finish() {
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

    private func startSession() {
        let duration = TimeInterval(settings.totalSeconds)
        sessionEndDate = Date().addingTimeInterval(duration)
        remaining  = duration
        timerState = .running
        screen     = .activeTimer
        audio.play(settings.startBell, volume: settings.volume)
        background.scheduleEnd(after: duration, bell: settings.endBell)
        scheduleTimer()
    }

    private func tick() {
        guard let endDate = sessionEndDate else { return }
        remaining = max(endDate.timeIntervalSinceNow, 0)
        if remaining == 0 { complete() }
    }

    private func complete() {
        cleanup()
        audio.play(settings.endBell, volume: settings.volume)
        screen = .sessionComplete
    }

    private func cleanup() {
        timer?.invalidate()
        timer          = nil
        timerState     = .idle
        sessionEndDate = nil
        background.cancel()
    }

    private func scheduleTimer() {
        let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    // Auto-pause on incoming call or other audio interruption
    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil, queue: .main
        ) { [weak self] note in
            guard
                let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                AVAudioSession.InterruptionType(rawValue: raw) == .began
            else { return }
            Task { @MainActor [weak self] in self?.pause() }
        }
    }

    // Reconcile elapsed time after app returns from background
    private func observeForeground() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.timerState == .running else { return }
                if let end = self.sessionEndDate, end.timeIntervalSinceNow <= 0 {
                    self.complete()
                }
            }
        }
    }
}
