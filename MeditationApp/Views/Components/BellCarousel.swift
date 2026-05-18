import SwiftUI

struct BellCarousel: View {
    @Binding var startBell: Bell
    @Binding var endBell: Bell
    var onPreview: (Bell) -> Void

    @State private var mode: Mode = .start

    private enum Mode: String, CaseIterable {
        case start = "Start"
        case end   = "End"
    }

    private var active: Bell { mode == .start ? startBell : endBell }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Start / End toggle
            HStack(spacing: 0) {
                ForEach(Mode.allCases, id: \.self) { m in
                    Button(m.rawValue) { mode = m }
                        .font(.subheadline)
                        .fontWeight(mode == m ? .semibold : .regular)
                        .foregroundStyle(mode == m ? .white : .white.opacity(0.35))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(mode == m ? Color.white.opacity(0.1) : Color.clear)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)

            HStack(spacing: 0) {
                ForEach(Bell.allCases, id: \.self) { bell in
                    BellCell(
                        bell: bell,
                        isSelected: active == bell,
                        onTap: {
                            if mode == .start { startBell = bell } else { endBell = bell }
                            onPreview(bell)
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

private struct BellCell: View {
    let bell: Bell
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.07))
                        .frame(width: 56, height: 56)
                    Image(systemName: bell.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.55))
                }
                Text(bell.displayName)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
