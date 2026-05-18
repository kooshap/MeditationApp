import SwiftUI

struct SettingsSummary: View {
    let settings: SessionSettings

    var body: some View {
        VStack(spacing: 0) {
            row("Duration",   durationText)
            divider
            row("Start Bell", settings.startBell.displayName)
            divider
            row("End Bell",   settings.endBell.displayName)
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 16)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(value).foregroundStyle(.white)
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var durationText: String {
        let t = settings.totalSeconds
        let h = t / 3600, m = (t % 3600) / 60, s = t % 60
        if h > 0 { return "\(h)h \(m)m \(s)s" }
        if m > 0 { return s > 0 ? "\(m)m \(s)s" : "\(m)m" }
        return "\(s)s"
    }
}
