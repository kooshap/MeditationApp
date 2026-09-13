import Foundation

struct SessionSettings: Codable {
    var hours: Int   = 0
    var minutes: Int = 10
    var seconds: Int = 0
    var startBell: Bell  = .tibetan
    var endBell: Bell    = .tibetan
    var volume: Float    = 0.8

    var totalSeconds: Int { hours * 3600 + minutes * 60 + seconds }

    private static let storageKey = "com.meditation.settings"

    static func load() -> SessionSettings {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(SessionSettings.self, from: data)
        else { return SessionSettings() }
        return decoded.clamped()
    }

    // Stored values aren't trusted: out-of-range numbers would overflow totalSeconds
    // or break the picker, so pull everything back into what the UI can produce
    private func clamped() -> SessionSettings {
        var s = self
        s.hours   = min(max(hours, 0), 23)
        s.minutes = min(max(minutes, 0), 59)
        s.seconds = min(max(seconds, 0), 59)
        s.volume  = volume.isFinite ? min(max(volume, 0), 1) : SessionSettings().volume
        return s
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
