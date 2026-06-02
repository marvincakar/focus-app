import SwiftUI

struct HeatmapView: View {
    @EnvironmentObject var sessionStore: SessionStore

    private let visibleWeeks = 18
    private let cellSize: CGFloat = 16
    private let cellSpacing: CGFloat = 4
    private let stepWeeks = 4
    private let minOffset = -260   // ~5 years back
    private let maxOffset = 0      // default (today centered) is the furthest forward
    private let calendar = Calendar.current

    // weekOffset == 0 -> today's week sits in the center column
    @State private var weekOffset = 0
    @State private var hoveredCol: Int? = nil

    private var halfVisible: Int { visibleWeeks / 2 }

    private var currentWeekSunday: Date {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        return calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(rangeLabel)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color("TextSecondary"))

            HStack(spacing: 12) {
                arrowButton(systemName: "chevron.left", disabled: weekOffset <= minOffset) {
                    weekOffset = max(minOffset, weekOffset - stepWeeks)
                }

                HStack(alignment: .top, spacing: cellSpacing) {
                    ForEach(0..<visibleWeeks, id: \.self) { col in
                        VStack(spacing: cellSpacing) {
                            ForEach(0..<7, id: \.self) { day in
                                let date = dateFor(col: col, day: day)
                                HeatmapCell(
                                    date: date,
                                    count: sessionStore.sessionCount(for: date),
                                    cellSize: cellSize
                                ) { hovering in
                                    hoveredCol = hovering ? col : (hoveredCol == col ? nil : hoveredCol)
                                }
                            }
                        }
                        .zIndex(hoveredCol == col ? 1 : 0)
                    }
                }

                arrowButton(systemName: "chevron.right", disabled: weekOffset >= maxOffset) {
                    weekOffset = min(maxOffset, weekOffset + stepWeeks)
                }
            }
        }
    }

    private func arrowButton(systemName: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(disabled ? Color("TextSecondary").opacity(0.3) : Color("TextPrimary"))
                .frame(width: 28, height: 28)
                .background(Color("ButtonBg"), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func columnWeekStart(_ col: Int) -> Date {
        let offsetWeeks = (weekOffset - halfVisible) + col
        return calendar.date(byAdding: .day, value: offsetWeeks * 7, to: currentWeekSunday) ?? currentWeekSunday
    }

    private func dateFor(col: Int, day: Int) -> Date {
        calendar.date(byAdding: .day, value: day, to: columnWeekStart(col)) ?? currentWeekSunday
    }

    private var rangeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let first = columnWeekStart(0)
        let last = columnWeekStart(visibleWeeks - 1)
        let firstStr = formatter.string(from: first)
        let lastStr = formatter.string(from: last)
        return firstStr == lastStr ? firstStr : "\(firstStr) – \(lastStr)"
    }
}

struct HeatmapCell: View {
    let date: Date
    let count: Int
    let cellSize: CGFloat
    var onHover: (Bool) -> Void = { _ in }

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
            .onHover { hovering in
                isHovered = hovering
                onHover(hovering)
            }
            .overlay(alignment: .bottom) {
                if isHovered {
                    Text(tooltipText)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color("ButtonBg"))
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        )
                        .fixedSize()
                        .offset(y: -(cellSize + 6))
                        .zIndex(1)
                        .allowsHitTesting(false)
                }
            }
    }
}
