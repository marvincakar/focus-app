import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let phase: Phase
    let timeString: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("RingTrack"), lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(phase.accentColorName),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Text(timeString)
                .font(.system(size: 48, weight: .medium, design: .monospaced))
                .foregroundColor(Color("TextPrimary"))
        }
        .frame(width: 220, height: 220)
    }
}

struct PhasePickerView: View {
    @EnvironmentObject var model: PomodoroModel

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color("PillTrack"))
                .frame(height: 34)

            HStack(spacing: 0) {
                ForEach(Phase.allCases, id: \.self) { phase in
                    Button {
                        model.selectPhase(phase)
                    } label: {
                        Text(phase.rawValue)
                            .font(.system(size: 13, weight: model.phase == phase ? .semibold : .regular))
                            .foregroundColor(model.phase == phase ? Color("TextPrimary") : Color("TextSecondary"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(
                                Capsule()
                                    .fill(model.phase == phase ? Color("ButtonBg") : Color.clear)
                                    .padding(.horizontal, 2)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct ControlButtonsView: View {
    @EnvironmentObject var model: PomodoroModel

    var body: some View {
        HStack(spacing: 16) {
            Button {
                if model.isRunning { model.pause() } else { model.start() }
            } label: {
                Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(width: 52, height: 52)
                    .background(Color("ButtonBg"), in: Circle())
            }
            .buttonStyle(.plain)

            Button {
                model.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18))
                    .foregroundColor(Color("TextSecondary"))
                    .frame(width: 44, height: 44)
                    .background(Color("ButtonBg"), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }
}
