import SwiftUI

struct SessionCompleteView: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Session Complete")
                    .font(.title3.weight(.light))
                    .foregroundStyle(.white)

                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
    }
}
