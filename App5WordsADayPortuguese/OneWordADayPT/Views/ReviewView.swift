import SwiftUI

struct ReviewView: View {
    @Bindable var viewModel: AppViewModel
    @State private var currentIndex: Int = 0
    @State private var isRevealed: Bool = false
    @State private var sessionComplete: Bool = false
    @State private var correctCount: Int = 0
    @State private var totalReviewed: Int = 0
    @State private var revealTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakBanner

                    if sessionComplete {
                        sessionCompleteView
                    } else if viewModel.reviewWords.isEmpty {
                        emptyReviewView
                    } else {
                        reviewProgress
                        reviewCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.large)
            .task {
                viewModel.loadReviewWords()
            }
        }
    }

    private var streakBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("\(viewModel.currentStreak) day streak")
                .font(.subheadline.weight(.semibold))
            Spacer()
            let level = viewModel.currentLevel
            Label("Lv.\(level.rawValue) \(level.name)", systemImage: level.icon)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var reviewProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(currentIndex + 1) of \(viewModel.reviewWords.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("\(correctCount)")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                }
            }

            ProgressView(value: Double(currentIndex), total: Double(max(1, viewModel.reviewWords.count)))
                .tint(.blue)
        }
    }

    @ViewBuilder
    private var reviewCard: some View {
        if currentIndex < viewModel.reviewWords.count {
            let userWord = viewModel.reviewWords[currentIndex]
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text(userWord.partOfSpeech.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())

                    Text(userWord.displayPortuguese)
                        .font(.system(size: 36, weight: .bold))

                    if isRevealed {
                        Text(userWord.english)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.blue)
                            .transition(.scale.combined(with: .opacity))

                        if let word = VocabularyDatabase.shared.word(byId: userWord.wordId) {
                            VStack(alignment: .leading, spacing: 8) {
                                Divider()
                                Text(word.exampleSentence)
                                    .font(.body.weight(.medium))
                                Text(word.exampleTranslation)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        }

                        masteryIndicator(score: userWord.masteryScore)
                            .padding(.top, 8)
                    } else {
                        Button {
                            revealTrigger.toggle()
                            withAnimation(.snappy) {
                                isRevealed = true
                            }
                        } label: {
                            Text("Show answer")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.quaternary, in: Capsule())
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)

                if isRevealed {
                    reviewButtons(for: userWord)
                        .padding(.top, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .id(userWord.wordId)
            .animation(.snappy(duration: 0.3), value: isRevealed)
            .sensoryFeedback(.impact(weight: .light), trigger: revealTrigger)
        }
    }

    private func masteryIndicator(score: Int) -> some View {
        HStack(spacing: 8) {
            Text("Mastery")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: Double(score), total: 100)
                .tint(masteryColor(score))

            Text("\(score)%")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(masteryColor(score))
        }
    }

    private func masteryColor(_ score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 50 { return .orange }
        return .red
    }

    private func reviewButtons(for userWord: UserWord) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    viewModel.reviewIncorrect(userWord)
                    totalReviewed += 1
                    advanceReview()
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.semibold))
                    Text("Incorrect")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(.rect(cornerRadius: 14))
            }
            .sensoryFeedback(.error, trigger: totalReviewed)

            Button {
                withAnimation(.snappy) {
                    viewModel.reviewCorrect(userWord)
                    correctCount += 1
                    totalReviewed += 1
                    advanceReview()
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.semibold))
                    Text("Correct")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.green.opacity(0.1))
                .foregroundStyle(.green)
                .clipShape(.rect(cornerRadius: 14))
            }
            .sensoryFeedback(.success, trigger: correctCount)
        }
    }

    private func advanceReview() {
        isRevealed = false
        if currentIndex < viewModel.reviewWords.count - 1 {
            currentIndex += 1
        } else {
            sessionComplete = true
        }
    }

    private var sessionCompleteView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)

            Text("Review complete!")
                .font(.title2.weight(.bold))

            if totalReviewed > 0 {
                Text("\(correctCount)/\(totalReviewed) correct")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("\(Int(Double(correctCount) / Double(totalReviewed) * 100))% accuracy")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }

            if viewModel.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(viewModel.currentStreak) day streak")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }

            Button("Review Again") {
                currentIndex = 0
                isRevealed = false
                sessionComplete = false
                correctCount = 0
                totalReviewed = 0
                viewModel.loadReviewWords()
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .padding(.vertical, 40)
    }

    private var emptyReviewView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No reviews due")
                .font(.title2.weight(.bold))

            Text("Your learned words will appear here\nwhen they're due for review.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}
