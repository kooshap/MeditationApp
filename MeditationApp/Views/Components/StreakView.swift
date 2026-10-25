import SwiftUI

// Current streak above a row of dots for the last seven days, filled on days with a session
struct StreakView: View {
    let log: PracticeLog

    @State private var now = Date()

    var body: some View {
        let streak = log.streak(asOf: now)
        let days   = log.lastSevenDays(asOf: now)

        VStack(spacing: 14) {
            // Kept in the layout at zero so the screen doesn't shift once a streak starts
            Text("\(streak) day streak")
                .font(.footnote.weight(.light))
                .foregroundStyle(.white.opacity(0.55))
                .opacity(streak > 0 ? 1 : 0)

            HStack(spacing: 18) {
                ForEach(days, id: \.self) { day in
                    let isToday = Calendar.current.isDate(day, inSameDayAs: now)
                    VStack(spacing: 8) {
                        if log.practiced(on: day) {
                            Circle().fill(.white.opacity(0.85))
                                .frame(width: 10, height: 10)
                        } else {
                            Circle().strokeBorder(.white.opacity(isToday ? 0.5 : 0.2), lineWidth: 1)
                                .frame(width: 10, height: 10)
                        }
                        Text(weekdayLetter(day))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(isToday ? 0.55 : 0.25))
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(streak: streak, days: days))
        // Fires at midnight (and on time zone changes) so "today" moves on without a relaunch
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            now = Date()
        }
    }

    private func weekdayLetter(_ day: Date) -> String {
        let cal = Calendar.current
        return cal.veryShortWeekdaySymbols[cal.component(.weekday, from: day) - 1]
    }

    private func accessibilityText(streak: Int, days: [Date]) -> String {
        let practiced = days.filter { log.practiced(on: $0) }.count
        let week = "Meditated on \(practiced) of the last 7 days"
        return streak > 0 ? "\(streak) day streak. \(week)" : week
    }
}
