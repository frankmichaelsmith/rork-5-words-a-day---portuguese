import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    levelProgressCard
                    projectionCard
                    streakAndAccuracyRow
                    categoryCountsCard
                    streakCalendar
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var levelProgressCard: some View {
        let level = viewModel.currentLevel
        let progress = viewModel.levelProgress
        return VStack(spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: level.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.blue)
                    .frame(width: 48, height: 48)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Level \(level.rawValue)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(level.name)
                        .font(.title2.weight(.bold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.totalWordsLearned)")
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                    Text("words")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 6) {
                ProgressView(value: progress)
                    .tint(.blue)

                HStack {
                    Text("\(level.wordThreshold)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                    Spacer()
                    if let next = level.next {
                        Text("\(viewModel.wordsToNextLevel) words to \(next.name)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Max level reached!")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                    Text("\(level.nextLevelThreshold)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }
            }

            Text(level.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var projectionCard: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PROJECTED VOCABULARY")
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.projectedYearlyWords)")
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .monospacedDigit()
                    Text("words in one year")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue.opacity(0.3))
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var streakAndAccuracyRow: some View {
        HStack(spacing: 12) {
            MetricCard(
                title: "Current Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: "days",
                icon: "flame.fill",
                iconColor: .orange
            )
            MetricCard(
                title: "Weekly Accuracy",
                value: "\(Int(viewModel.weeklyAccuracy))%",
                subtitle: "last 7 days",
                icon: "target",
                iconColor: .green
            )
        }
    }

    private var categoryCountsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Words by Category")
                .font(.headline)

            let data = viewModel.countByPartOfSpeech
            if data.allSatisfy({ $0.1 == 0 }) {
                Text("Learn some words to see your breakdown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 0) {
                    ForEach(data, id: \.0) { item in
                        VStack(spacing: 8) {
                            Text("\(item.1)")
                                .font(.system(size: 28, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(typeColor(item.0))

                            Text(item.0)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                let total = data.reduce(0) { $0 + $1.1 }
                if total > 0 {
                    GeometryReader { geo in
                        HStack(spacing: 2) {
                            ForEach(data, id: \.0) { item in
                                let fraction = Double(item.1) / Double(total)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(typeColor(item.0))
                                    .frame(width: max(0, (geo.size.width - 4) * fraction))
                            }
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func typeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "noun": .blue
        case "verb": .orange
        case "adjective": .purple
        default: .gray
        }
    }

    private var streakCalendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activity")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Longest: \(viewModel.longestStreak) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            let calendarData = viewModel.studySessionsForCalendar()
            StreakCalendarView(data: calendarData)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.subheadline)
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .monospacedDigit()
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}
