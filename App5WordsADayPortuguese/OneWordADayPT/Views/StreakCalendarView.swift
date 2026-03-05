import SwiftUI

struct StreakCalendarView: View {
    let data: [Date: Int]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
    private let calendar = Calendar.current

    private var weeks: [[Date?]] {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -62, to: today) else { return [] }

        let weekdayOfStart = calendar.component(.weekday, from: startDate)
        let paddingBefore = weekdayOfStart - 1

        var allDays: [Date?] = Array(repeating: nil, count: paddingBefore)

        var current = startDate
        while current <= today {
            allDays.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? today
        }

        let remainder = allDays.count % 7
        if remainder != 0 {
            allDays += Array(repeating: nil as Date?, count: 7 - remainder)
        }

        return stride(from: 0, to: allDays.count, by: 7).map {
            Array(allDays[$0..<min($0 + 7, allDays.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if dayIndex < week.count, let date = week[dayIndex] {
                            let count = data[date] ?? 0
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(cellColor(count: count))
                                .frame(height: 14)
                                .frame(maxWidth: .infinity)
                        } else {
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(Color.clear)
                                .frame(height: 14)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private func cellColor(count: Int) -> Color {
        switch count {
        case 0: Color(.quaternarySystemFill)
        case 1...2: Color.green.opacity(0.3)
        case 3...5: Color.green.opacity(0.55)
        default: Color.green.opacity(0.85)
        }
    }
}
