import Foundation
import Combine
import UserNotifications
import AppKit

enum Phase: String, CaseIterable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var duration: TimeInterval {
        switch self {
        case .focus:      return 50 * 60
        case .shortBreak: return 10 * 60
        case .longBreak:  return 20 * 60
        }
    }

    var accentColorName: String {
        switch self {
        case .focus:      return "AccentFocus"
        case .shortBreak: return "AccentBreak"
        case .longBreak:  return "AccentLong"
        }
    }
}

@MainActor
final class PomodoroModel: ObservableObject {
    @Published var phase: Phase = .focus
    @Published var timeRemaining: TimeInterval = Phase.focus.duration
    @Published var isRunning = false
    @Published var completedFocusSessions = 0

    private var cancellable: AnyCancellable?
    private var lastTick: Date?

    var progress: Double {
        1.0 - (timeRemaining / phase.duration)
    }

    var timeString: String {
        let m = Int(timeRemaining) / 60
        let s = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", m, s)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        lastTick = Date()
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        cancellable?.cancel()
        cancellable = nil
    }

    func reset() {
        pause()
        timeRemaining = phase.duration
    }

    func selectPhase(_ newPhase: Phase) {
        pause()
        phase = newPhase
        timeRemaining = newPhase.duration
    }

    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            phaseCompleted()
        }
    }

    private func phaseCompleted() {
        pause()

        if phase == .focus {
            completedFocusSessions += 1
            SessionStore.shared.recordSession()
            let nextPhase: Phase = completedFocusSessions % 4 == 0 ? .longBreak : .shortBreak
            sendNotification(completedPhase: .focus, nextPhase: nextPhase)
            phase = nextPhase
        } else {
            sendNotification(completedPhase: phase, nextPhase: .focus)
            phase = .focus
        }

        timeRemaining = phase.duration
        playAlertSound()
    }

    private func playAlertSound() {
        NSSound(named: .init("Glass"))?.play()
    }

    private func sendNotification(completedPhase: Phase, nextPhase: Phase) {
        let content = UNMutableNotificationContent()
        switch completedPhase {
        case .focus:
            content.title = "Focus session complete!"
            content.body = nextPhase == .longBreak
                ? "Time for a long break — press play when ready."
                : "Time for a short break — press play when ready."
        case .shortBreak:
            content.title = "Short break over"
            content.body = "Press play to start your next focus session."
        case .longBreak:
            content.title = "Long break over"
            content.body = "Press play to start your next focus session."
        }
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Notification error: \(error)") }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
