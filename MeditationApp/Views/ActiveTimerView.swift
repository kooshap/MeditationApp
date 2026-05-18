import SwiftUI

struct ActiveTimerView: View {
    @Bindable var vm: MeditationViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Countdown display
                Text(timeString(vm.remaining))
                    .font(.system(size: 76, weight: .thin, design: .default))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.4), value: Int(vm.remaining))

                Spacer()

                // Controls
                Group {
                    if vm.timerState == .running {
                        Button {
                            vm.pause()
                        } label: {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .buttonStyle(TimerControlStyle())
                    } else if vm.timerState == .paused {
                        HStack(spacing: 40) {
                            Button("Finish") { vm.finish() }
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.4))

                            Button {
                                vm.resume()
                            } label: {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                            .buttonStyle(TimerControlStyle())
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: vm.timerState)

                Spacer().frame(height: 72)
            }
        }
        // Keep screen awake while the timer is visible
        .onAppear  { UIApplication.shared.isIdleTimerDisabled = true  }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .preferredColorScheme(.dark)
    }

    private func timeString(_ t: TimeInterval) -> String {
        let total = Int(max(t, 0))
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
}
