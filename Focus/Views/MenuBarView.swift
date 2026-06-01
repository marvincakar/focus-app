import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var model: PomodoroModel
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(model.phase.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                StreakBadge(streak: sessionStore.streak)
            }

            Text(model.timeString)
                .font(.system(size: 36, weight: .medium, design: .monospaced))
                .foregroundColor(Color("TextPrimary"))

            HStack(spacing: 10) {
                Button {
                    if model.isRunning { model.pause() } else { model.start() }
                } label: {
                    Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 40, height: 36)
                        .background(Color("ButtonBg"), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button {
                    model.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                        .frame(width: 40, height: 36)
                        .background(Color("ButtonBg"), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Button {
                openMainWindow()
            } label: {
                Text("Open Focus")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Color("ButtonBg"), in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                NSApp.terminate(nil)
            } label: {
                Text("Quit")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Color("ButtonBg"), in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 220)
        .background(Color("Background"))
    }

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows {
            if window.identifier?.rawValue == "main" {
                window.makeKeyAndOrderFront(nil)
                break
            }
        }
    }
}
