import SwiftUI

struct SoundPickerView: View {
    @StateObject private var soundPlayer = SoundPlayer()

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AmbientSound.allCases) { sound in
                        SoundChip(
                            sound: sound,
                            isSelected: soundPlayer.currentSound == sound
                        ) {
                            if soundPlayer.currentSound == sound {
                                soundPlayer.stop()
                            } else {
                                soundPlayer.play(sound)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }

            if soundPlayer.currentSound != .off {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextSecondary"))
                    Slider(value: $soundPlayer.volume, in: 0...1)
                        .tint(Color("AccentFocus"))
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextSecondary"))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: soundPlayer.currentSound == .off)
    }
}

struct SoundChip: View {
    let sound: AmbientSound
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(sound.emoji) \(sound.rawValue)")
                .font(.system(size: 13))
                .foregroundColor(isSelected ? Color("TextPrimary") : Color("TextSecondary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("ChipActive") : Color.clear)
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? Color.clear : Color("Divider"), lineWidth: 1)
                        )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
