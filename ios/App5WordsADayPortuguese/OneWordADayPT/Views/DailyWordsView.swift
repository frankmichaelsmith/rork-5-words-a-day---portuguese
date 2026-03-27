import SwiftUI

struct DailyWordsView: View {
    @Bindable var viewModel: AppViewModel
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Learn")
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                headerSection
                levelBadge

                if viewModel.todayCompleted || viewModel.showCompletionMessage {
                    completionView
                } else if viewModel.dailyWords.isEmpty {
                    emptyStateView
                } else {
                    progressIndicator
                    currentCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        HStack(spacing: 16) {
            StatPill(
                icon: "flame.fill",
                value: "\(viewModel.currentStreak)",
                label: "Streak",
                color: .orange
            )

            StatPill(
                icon: "book.closed.fill",
                value: "\(viewModel.totalWordsLearned)",
                label: "Words",
                color: .blue
            )

            StatPill(
                icon: "arrow.clockwise",
                value: "\(viewModel.wordsLearnedToday)",
                label: "Learned",
                color: .green
            )
        }
    }

    private var levelBadge: some View {
        let level = viewModel.currentLevel
        return HStack(spacing: 10) {
            Image(systemName: level.icon)
                .font(.subheadline)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(level.rawValue): \(level.name)")
                    .font(.subheadline.weight(.semibold))
                ProgressView(value: viewModel.levelProgress)
                    .tint(.blue)
            }

            Spacer()

            Text("\(viewModel.wordsToNextLevel)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
            + Text(" to go")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.dailyWords.count, id: \.self) { index in
                Capsule()
                    .fill(index <= viewModel.currentCardIndex ? Color.blue : Color(.quaternarySystemFill))
                    .frame(height: 4)
                    .animation(.snappy, value: viewModel.currentCardIndex)
            }
        }
    }

    @ViewBuilder
    private var currentCard: some View {
        if viewModel.currentCardIndex < viewModel.dailyWords.count {
            let word = viewModel.dailyWords[viewModel.currentCardIndex]
            FlashcardView(
                word: word,
                isFlipped: viewModel.isFlipped,
                onFlip: {
                    withAnimation(.snappy) {
                        viewModel.isFlipped = true
                    }
                },
                onLearn: {
                    withAnimation(.snappy) {
                        viewModel.learnWord(word)
                    }
                },
                onKnown: {
                    withAnimation(.snappy) {
                        viewModel.markKnown(word)
                    }
                }
            )
            .id(word.id)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .sensoryFeedback(.impact(weight: .light), trigger: viewModel.currentCardIndex)
        }
    }

    private var completionTitle: String {
        switch viewModel.sessionNumber {
        case 1: return "Daily session complete"
        case 2: return "Extra session complete"
        default: return "3rd daily session complete"
        }
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: viewModel.showCompletionMessage)

            Text(completionTitle)
                .font(.title2.weight(.bold))

            if viewModel.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(viewModel.currentStreak) day streak!")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }

            if viewModel.canStartAnotherSession {
                Text("You've learned your words for this session.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    Button {
                        withAnimation(.snappy) {
                            viewModel.startAnotherSession()
                        }
                    } label: {
                        Label("Learn More Words", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                    }

                    if viewModel.reviewCount > 0 {
                        Text("\(viewModel.reviewCount) words ready for review")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            } else {
                Text("Take some time to review these words\nbefore learning more tomorrow.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    selectedTab = 1
                } label: {
                    Text("\(viewModel.wordsLearnedToday) words ready for review")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 40)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Amazing progress!")
                .font(.title2.weight(.bold))

            Text("You've gone through all available words\nat this difficulty level.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                withAnimation(.snappy) {
                    viewModel.startAnotherSession()
                }
            } label: {
                Label("Learn More Words", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 14))
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 40)
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                Text(value)
                    .font(.headline.weight(.bold))
                    .monospacedDigit()
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
