import AVFoundation

final class AudioEngine: NSObject {
    private var player: AVAudioPlayer?

    // Call once at app startup — configures session for background playback
    func configure() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(_ bell: Bell, volume: Float) {
        guard let url = Bundle.main.url(forResource: bell.filename, withExtension: "mp3") else { return }
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: url)
        player?.volume = volume
        player?.prepareToPlay()
        player?.play()
    }

    func stop() {
        player?.stop()
    }
}
