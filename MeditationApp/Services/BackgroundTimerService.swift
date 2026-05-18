import UserNotifications

// Schedules a local notification as a fallback bell when the app is backgrounded or locked.
// The in-app AudioEngine handles the bell when foregrounded; this handles the rest.
final class BackgroundTimerService {
    private let notificationID = "com.meditation.sessionEnd"

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.sound, .alert]) { _, _ in }
    }

    func scheduleEnd(after seconds: TimeInterval, bell: Bell) {
        guard seconds > 0 else { return }
        cancel()

        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body  = "Your meditation session has ended."
        content.sound = UNNotificationSound(
            named: UNNotificationSoundName("\(bell.filename).mp3")
        )

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}
