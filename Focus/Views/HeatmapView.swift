import SwiftUI

struct HeatmapView: View {
    @EnvironmentObject var sessionStore: SessionStore

    private let weeks = 52
    private let cellSize: CGFloat = 16
    private let cellSpacing: CGFloat = 4
    private let calendar = Calendar.current

    private var gridStartDate: Date {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToSunday = weekday - 1
        let lastSunday = calendar.date(byAdding: .day, value: -daysToSunday, to: today)!
        return calendar.date(byAdding: .day, value: -(weeks - 1) * 7, to: lastSunday)!
    }

    var body: some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(0..<weeks, id: \.self) { week in
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { day in
                        let date = dateFor(week: week, day: day)
                        HeatmapCell(date: date, count: sessionStore.sessionCount(for: date), cellSize: cellSize)
                    }
                }
            }
        }
    }

    private func dateFor(week: Int, day: Int) -> Date {
        calendar.date(byAdding: .day, value: week * 7 + day, to: gridStartDate) ?? Date()
    }
}

struct HeatmapCell: View {
    let date: Date
    let count: Int
    let cellSize: CGFloat

    @State private var isHovered = false
    private let calendar = Calendar.current

    private var isFuture: Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }

    private var colorName: String {
        if isFuture { return "HeatmapEmpty" }
        switch count {
        case 0:  return "HeatmapL0"
        case 1:  return "HeatmapL1"
        case 2:  return "HeatmapL2"
        case 3:  return "HeatmapL3"
        default: return "HeatmapL4"
        }
    }

    private var tooltipText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateStr = formatter.string(from: date)
        if isFuture || count == 0 { return dateStr }
        let totalMinutes = count * 50
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let timeStr: String
        if hours == 0 { timeStr = "\(minutes)min" }
        else if minutes == 0 { timeStr = "\(hours)h" }
        else { timeStr = "\(hours)h \(minutes)min" }
        return "\(dateStr): \(timeStr)"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(colorName))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(isHovered ? Color("TextSecondary").opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .onHover { hovering in isHovered = hovering }
            .help(tooltipText)
    }
}
