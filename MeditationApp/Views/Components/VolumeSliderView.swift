import SwiftUI

struct VolumeSliderView: View {
    @Binding var volume: Float

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.35))
            Slider(value: $volume, in: 0...1)
                .tint(Color.white.opacity(0.55))
            Image(systemName: "speaker.wave.3.fill")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}
