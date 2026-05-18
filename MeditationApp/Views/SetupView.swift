import SwiftUI

struct SetupView: View {
    @Bindable var vm: MeditationViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 36) {
                    Text("Meditate")
                        .font(.title2.weight(.ultraLight))
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.top, 32)

                    DurationWheelPicker(
                        hours:   $vm.settings.hours,
                        minutes: $vm.settings.minutes,
                        seconds: $vm.settings.seconds
                    )
                    .frame(height: 180)

                    BellCarousel(
                        startBell: $vm.settings.startBell,
                        endBell:   $vm.settings.endBell,
                        onPreview: { vm.previewBell($0) }
                    )

                    VolumeSliderView(volume: $vm.settings.volume)
                        .padding(.horizontal, 24)

                    Text("For the best experience, switch your device to Do Not Disturb.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)

                    Button("Start") { vm.requestStart() }
                        .buttonStyle(StartButtonStyle())
                        .disabled(vm.settings.totalSeconds == 0)
                        .opacity(vm.settings.totalSeconds == 0 ? 0.35 : 1)
                        .padding(.bottom, 52)
                }
            }
        }
        .alert("Enable Notifications?", isPresented: $vm.showPermissionPrompt) {
            Button("Allow") { vm.allowNotificationsAndStart() }
            Button("Not Now", role: .cancel) { vm.skipNotificationsAndStart() }
        } message: {
            Text("We'll send one notification when your session ends — useful if you lock your screen mid-session.")
        }
    }
}
