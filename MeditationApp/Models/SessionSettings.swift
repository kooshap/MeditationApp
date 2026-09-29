import Foundation

struct SessionSettings: Codable {
    var hours: Int   = 0
    var minutes: Int = 10
    var seconds: Int = 0
    var bell: Bell       = .tibetan   // rung at both the start and the end of a session
    var volume: Float    = 0.8

    var totalSeconds: Int { hours * 3600 + minutes * 60 + seconds }

    init() {}

    private enum CodingKeys: String, CodingKey {
        case hours, minutes, seconds, bell, volume
        case startBell  // legacy: separate start/end bells, read only for migration
    }

    // Older installs saved startBell/endBell instead of bell; carry the start bell over
    // rather than failing to decode and losing the rest of the saved settings
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hours   = try c.decode(Int.self, forKey: .hours)
        minutes = try c.decode(Int.self, forKey: .minutes)
        seconds = try c.decode(Int.self, forKey: .seconds)
        volume  = try c.decode(Float.self, forKey: .volume)
        bell    = try c.decodeIfPresent(Bell.self, forKey: .bell)
            ?? c.decodeIfPresent(Bell.self, forKey: .startBell)
            ?? .tibetan
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(hours, forKey: .hours)
        try c.encode(minutes, forKey: .minutes)
        try c.encode(seconds, forKey: .seconds)
        try c.encode(bell, forKey: .bell)
        try c.encode(volume, forKey: .volume)
    }

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
