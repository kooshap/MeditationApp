import SwiftUI

struct ContentView: View {
    @State private var vm = MeditationViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if vm.screen == .setup {
                SetupView(vm: vm)
                    .transition(.opacity)
            } else if vm.screen == .activeTimer {
                ActiveTimerView(vm: vm)
                    .transition(.opacity)
            } else if vm.screen == .sessionComplete {
                SessionCompleteView(onDismiss: { vm.dismissComplete() })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.55), value: vm.screen)
        .preferredColorScheme(.dark)
    }
}
