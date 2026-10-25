import Foundation

// Days the user meditated, stored as local calendar days ("2026-10-25") rather than
// timestamps, so travelling across time zones never moves a past session to another day
struct PracticeLog {
    private(set) var days: Set<String>

    private static let storageKey = "com.meditation.practiceDays"

    static func load() -> PracticeLog {
        PracticeLog(days: Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? []))
    }

    mutating func record(_ date: Date = Date()) {
        guard days.insert(Self.key(for: date)).inserted else { return }
        UserDefaults.standard.set(days.sorted(), forKey: Self.storageKey)
    }

    func practiced(on date: Date) -> Bool {
        days.contains(Self.key(for: date))
    }

    // Consecutive days up to today. Today without a session yet doesn't break the
    // streak (the day isn't over), so counting starts from yesterday in that case
    func streak(asOf now: Date = Date()) -> Int {
        let cal = Calendar.current
        var day = practiced(on: now) ? now : cal.date(byAdding: .day, value: -1, to: now)!
        var count = 0
        while practiced(on: day) {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }

    // Oldest first, ending with today
    func lastSevenDays(asOf now: Date = Date()) -> [Date] {
        (0..<7).reversed().map { Calendar.current.date(byAdding: .day, value: -$0, to: now)! }
    }

    private static func key(for date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
}
