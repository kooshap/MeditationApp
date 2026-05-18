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
        return decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
