import Foundation
import Combine

final class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published private(set) var sessions: [String: Int] = [:]

    private let key = "focus_sessions"
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private init() {
        sessions = (UserDefaults.standard.dictionary(forKey: key) as? [String: Int]) ?? [:]
    }

    func recordSession(on date: Date = Date()) {
        let key = formatter.string(from: date)
        sessions[key, default: 0] += 1
        persist()
    }

    func sessionCount(for date: Date) -> Int {
        sessions[formatter.string(from: date)] ?? 0
    }

    var streak: Int {
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: Date())
        if sessionCount(for: date) == 0 {
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        var count = 0
        while sessionCount(for: date) > 0 {
            count += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return count
    }

    private func persist() {
        UserDefaults.standard.set(sessions, forKey: key)
    }
}
