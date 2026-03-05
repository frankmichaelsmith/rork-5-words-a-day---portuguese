import SwiftUI

struct RecallView: View {
    @Bindable var viewModel: AppViewModel
    @State private var recallWords: [UserWord] = []
    @State private var currentIndex: Int = 0
    @State private var userInput: String = ""
    @State private var answerState: AnswerState = .waiting
    @State private var sessionComplete: Bool = false
    @State private var correctCount: Int = 0
    @State private var totalAttempted: Int = 0
    @State private var conjugationChallenge: ConjugationPrompt?
    @State private var isConjugationRound: Bool = false
    @State private var checkTrigger: Bool = false
    @State private var nextTrigger: Bool = false
    @FocusState private var isInputFocused: Bool

    private struct ConjugationPrompt {
        let userWord: UserWord
        let pronoun: String
        let tense: String
        let answer: String
        let infinitive: String
    }

    private enum AnswerState {
        case waiting
        case correct
        case incorrect
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakBanner

                    if sessionComplete {
                        sessionCompleteView
                    } else if recallWords.isEmpty && conjugationChallenge == nil {
                        emptyView
                    } else {
                        recallProgress

                        if isConjugationRound, let challenge = conjugationChallenge {
                            conjugationCard(challenge)
                        } else {
                            recallCard
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                isInputFocused = false
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recall")
            .navigationBarTitleDisplayMode(.large)
            .task {
                loadRecallWords()
            }
            .sensoryFeedback(.success, trigger: correctCount)
            .sensoryFeedback(.error, trigger: totalAttempted - correctCount)
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

    private func loadRecallWords() {
        let eligible = viewModel.allUserWords.filter { !$0.isKnown && $0.masteryScore < 90 }
        var items = Array(eligible.shuffled().prefix(8))

        if let conjData = viewModel.conjugationChallenge(),
           !items.contains(where: { $0.wordId == conjData.userWord.wordId }),
           let word = VocabularyDatabase.shared.word(byId: conjData.userWord.wordId),
           let conj = word.conjugations {
            conjugationChallenge = ConjugationPrompt(
                userWord: conjData.userWord,
                pronoun: conjData.pronoun,
                tense: conjData.tense,
                answer: conjData.answer,
                infinitive: conj.infinitive
            )
        } else if let conjData = viewModel.conjugationChallenge() {
            if let word = VocabularyDatabase.shared.word(byId: conjData.userWord.wordId),
               let conj = word.conjugations {
                conjugationChallenge = ConjugationPrompt(
                    userWord: conjData.userWord,
                    pronoun: conjData.pronoun,
                    tense: conjData.tense,
                    answer: conjData.answer,
                    infinitive: conj.infinitive
                )
            }
        }

        recallWords = items
        currentIndex = 0
        sessionComplete = false
        correctCount = 0
        totalAttempted = 0
        isConjugationRound = false
    }

    private var recallProgress: some View {
        let totalItems = recallWords.count + (conjugationChallenge != nil ? 1 : 0)
        let currentPos = isConjugationRound ? totalItems : currentIndex + 1
        return HStack {
            Text("\(currentPos) of \(totalItems)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 12) {
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Label("\(totalAttempted - correctCount)", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
            .font(.subheadline.weight(.semibold))
            .monospacedDigit()
        }
    }

    @ViewBuilder
    private var recallCard: some View {
        if currentIndex < recallWords.count {
            let userWord = recallWords[currentIndex]

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("TRANSLATE TO PORTUGUESE")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)

                    Text(userWord.english)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(userWord.partOfSpeech.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }

                TextField("Type in Portuguese...", text: $userInput)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isInputFocused)
                    .padding(16)
                    .background(inputBackground, in: .rect(cornerRadius: 14))
                    .onSubmit {
                        checkAnswer(userWord)
                    }
                    .submitLabel(.done)

                if answerState != .waiting {
                    answerFeedback(for: userWord)
                        .transition(.scale.combined(with: .opacity))
                }

                if answerState == .waiting {
                    Button("Check") {
                        checkAnswer(userWord)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                } else {
                    Button("Next") {
                        withAnimation(.snappy) {
                            advanceRecall()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
            .id(userWord.wordId)
            .onAppear {
                isInputFocused = true
            }
        }
    }

    private func conjugationCard(_ challenge: ConjugationPrompt) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                Text("CONJUGATION CHALLENGE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(.orange)

                HStack(spacing: 10) {
                    Text(challenge.pronoun)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))

                    Text(challenge.infinitive)
                        .font(.system(size: 28, weight: .bold))
                }

                Text(challenge.tense)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1), in: Capsule())
            }

            TextField("Conjugated form...", text: $userInput)
                .font(.title3)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isInputFocused)
                .padding(16)
                .background(inputBackground, in: .rect(cornerRadius: 14))
                .onSubmit {
                    checkConjugationAnswer(challenge)
                }
                .submitLabel(.done)

            if answerState != .waiting {
                conjugationFeedback(challenge)
                    .transition(.scale.combined(with: .opacity))
            }

            if answerState == .waiting {
                Button("Check") {
                    checkConjugationAnswer(challenge)
                }
                .buttonStyle(.borderedProminent)
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            } else {
                Button("Next") {
                    withAnimation(.snappy) {
                        sessionComplete = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        .onAppear {
            isInputFocused = true
        }
    }

    private func conjugationFeedback(_ challenge: ConjugationPrompt) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: answerState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(answerState == .correct ? .green : .red)
                Text(answerState == .correct ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .foregroundStyle(answerState == .correct ? .green : .red)
            }

            if answerState == .incorrect {
                Text("Answer: **\(challenge.answer)**")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func checkConjugationAnswer(_ challenge: ConjugationPrompt) {
        let isCorrect = SpacedRepetitionEngine.checkAccentForgiveness(userInput, challenge.answer)
        totalAttempted += 1

        withAnimation(.snappy) {
            if isCorrect {
                answerState = .correct
                correctCount += 1
                viewModel.reviewCorrect(challenge.userWord)
            } else {
                answerState = .incorrect
                viewModel.reviewIncorrect(challenge.userWord)
            }
        }

        isInputFocused = false
    }

    private var inputBackground: Color {
        switch answerState {
        case .waiting: Color(.tertiarySystemGroupedBackground)
        case .correct: Color.green.opacity(0.1)
        case .incorrect: Color.red.opacity(0.1)
        }
    }

    private func answerFeedback(for userWord: UserWord) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: answerState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(answerState == .correct ? .green : .red)
                Text(answerState == .correct ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .foregroundStyle(answerState == .correct ? .green : .red)
            }

            if answerState == .incorrect {
                Text("Answer: **\(userWord.displayPortuguese)**")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func checkAnswer(_ userWord: UserWord) {
        let isCorrect = viewModel.checkRecallAnswer(userInput, expected: userWord.portuguese)
        totalAttempted += 1

        withAnimation(.snappy) {
            if isCorrect {
                answerState = .correct
                correctCount += 1
                viewModel.reviewCorrect(userWord)
            } else {
                answerState = .incorrect
                viewModel.reviewIncorrect(userWord)
            }
        }

        isInputFocused = false
    }

    private func advanceRecall() {
        userInput = ""
        answerState = .waiting
        if currentIndex < recallWords.count - 1 {
            currentIndex += 1
            isInputFocused = true
        } else if conjugationChallenge != nil && !isConjugationRound {
            isConjugationRound = true
            isInputFocused = true
        } else {
            sessionComplete = true
        }
    }

    private var sessionCompleteView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)

            Text("Recall complete!")
                .font(.title2.weight(.bold))

            if totalAttempted > 0 {
                Text("\(correctCount)/\(totalAttempted) correct")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("\(Int(Double(correctCount) / Double(totalAttempted) * 100))% accuracy")
                    .font(.subheadline)
                    .foregroundStyle(.purple)
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

            Button("Practice Again") {
                loadRecallWords()
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .padding(.vertical, 40)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No words to practice")
                .font(.title2.weight(.bold))

            Text("Learn some words first, then come\nback to test your recall.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}
