import AVFoundation

// To add ambient sounds, place .mp3 files in the Focus/Focus/Resources/ folder
// and add them to the Xcode target. The expected filenames are:
//   rain.mp3, fireplace.mp3, train.mp3, ocean.mp3, dark_noise.mp3
// The app will run silently if any file is missing.

enum AmbientSound: String, CaseIterable, Identifiable {
    case off        = "Off"
    case rain       = "Rain"
    case fireplace  = "Fireplace"
    case train      = "Train"
    case ocean      = "Ocean"
    case darkNoise  = "Dark Noise"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .off:       return "🔇"
        case .rain:      return "🌧"
        case .fireplace: return "🔥"
        case .train:     return "🚂"
        case .ocean:     return "🌊"
        case .darkNoise: return "🌑"
        }
    }

    var filename: String? {
        switch self {
        case .off:       return nil
        case .rain:      return "rain"
        case .fireplace: return "fireplace"
        case .train:     return "train"
        case .ocean:     return "ocean"
        case .darkNoise: return "dark_noise"
        }
    }
}

final class SoundPlayer: ObservableObject {
    @Published var currentSound: AmbientSound = .off
    @Published var volume: Double = 0.5 {
        didSet { player?.volume = Float(volume) }
    }

    private var player: AVAudioPlayer?

    func play(_ sound: AmbientSound) {
        currentSound = sound
        player?.stop()
        player = nil

        guard let filename = sound.filename else { return }
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("[SoundPlayer] Missing audio file: \(filename).mp3 — add it to Focus/Focus/Resources/")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = Float(volume)
            player?.play()
        } catch {
            print("[SoundPlayer] Failed to play \(filename).mp3: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        currentSound = .off
    }
}
