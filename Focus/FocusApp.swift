import SwiftUI
import UserNotifications

@main
struct FocusApp: App {
    @StateObject private var pomodoroModel = PomodoroModel()
    @StateObject private var sessionStore = SessionStore.shared

    var body: some Scene {
        Window("Focus", id: "main") {
            ContentView()
                .environmentObject(pomodoroModel)
                .environmentObject(sessionStore)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1020, height: 720)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(pomodoroModel)
                .environmentObject(sessionStore)
        } label: {
            MenuBarLabel(pomodoroModel: pomodoroModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var pomodoroModel: PomodoroModel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
            if pomodoroModel.isRunning {
                Text(pomodoroModel.timeString)
                    .monospacedDigit()
                    .font(.system(size: 12))
            }
        }
    }
}
