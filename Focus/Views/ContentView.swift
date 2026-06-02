import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: PomodoroModel
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("focus.")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(Color("TextPrimary"))
                    Spacer()
                    StreakBadge(streak: sessionStore.streak)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)

                // Phase picker
                PhasePickerView()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Timer ring
                TimerRingView(
                    progress: model.progress,
                    phase: model.phase,
                    timeString: model.timeString
                )
                .padding(.bottom, 24)

                // Controls
                ControlButtonsView()
                    .padding(.bottom, 24)

                Divider()
                    .background(Color("Divider"))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Sound picker
                SoundPickerView()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                Divider()
                    .background(Color("Divider"))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Heatmap
                HeatmapView()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .frame(minWidth: 1020, minHeight: 720)
        .background(Color("Background"))
        .onAppear {
            model.requestNotificationPermission()
        }
    }
}

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("🔥")
                .font(.system(size: 20))
            Text("\(streak)")
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundColor(Color("TextPrimary"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color("ButtonBg"), in: Capsule())
    }
}
