import SwiftUI

struct BellCarousel: View {
    @Binding var selection: Bell
    var onPreview: (Bell) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Bell.allCases, id: \.self) { bell in
                BellCell(
                    bell: bell,
                    isSelected: selection == bell,
                    onTap: {
                        selection = bell
                        onPreview(bell)
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
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
        .accessibilityLabel(bell.displayName)
        .accessibilityHint("Selects this bell and plays a preview")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
