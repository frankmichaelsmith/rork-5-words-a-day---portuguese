import SwiftUI
import SwiftData

nonisolated enum VocabSortOption: String, CaseIterable, Sendable {
    case mastery = "Mastery"
    case lastTested = "Last Tested"
    case frequency = "Frequency"
    case alphabetical = "A-Z"
}

nonisolated enum VocabFilterOption: String, CaseIterable, Sendable {
    case all = "All"
    case nouns = "Nouns"
    case verbs = "Verbs"
    case adjectives = "Adjectives"
}

struct VocabularyListView: View {
    @Bindable var viewModel: AppViewModel
    @State private var searchText: String = ""
    @State private var sortOption: VocabSortOption = .mastery
    @State private var filterOption: VocabFilterOption = .all
    @State private var selectedWord: UserWord?

    private var filteredWords: [UserWord] {
        var words = viewModel.allUserWords

        if !searchText.isEmpty {
            words = words.filter {
                $0.portuguese.localizedStandardContains(searchText) ||
                $0.english.localizedStandardContains(searchText)
            }
        }

        switch filterOption {
        case .all: break
        case .nouns: words = words.filter { $0.partOfSpeech == "noun" }
        case .verbs: words = words.filter { $0.partOfSpeech == "verb" }
        case .adjectives: words = words.filter { $0.partOfSpeech == "adjective" }
        }

        switch sortOption {
        case .mastery:
            words.sort { $0.masteryScore > $1.masteryScore }
        case .lastTested:
            words.sort { ($0.lastTestedDate ?? .distantPast) > ($1.lastTestedDate ?? .distantPast) }
        case .frequency:
            words.sort { $0.frequencyRank < $1.frequencyRank }
        case .alphabetical:
            words.sort { $0.portuguese.localizedCompare($1.portuguese) == .orderedAscending }
        }

        return words
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.allUserWords.isEmpty {
                    ContentUnavailableView(
                        "No Words Yet",
                        systemImage: "book.closed",
                        description: Text("Words you learn will appear here.")
                    )
                } else {
                    List {
                        filterSection

                        ForEach(filteredWords, id: \.wordId) { userWord in
                            Button {
                                selectedWord = userWord
                            } label: {
                                WordRow(userWord: userWord)
                            }
                            .tint(.primary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(viewModel.currentStreak)")
                            .font(.subheadline.weight(.bold))
                            .monospacedDigit()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search words")
            .sheet(item: $selectedWord) { userWord in
                WordDetailSheet(userWord: userWord)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var filterSection: some View {
        Section {
            HStack(spacing: 8) {
                ForEach(VocabFilterOption.allCases, id: \.rawValue) { option in
                    Button {
                        withAnimation(.snappy) {
                            filterOption = option
                        }
                    } label: {
                        Text(option.rawValue)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                filterOption == option ? Color.blue : Color(.quaternarySystemFill),
                                in: Capsule()
                            )
                            .foregroundStyle(filterOption == option ? .white : .primary)
                    }
                }
                Spacer()
            }

            Picker("Sort", selection: $sortOption) {
                ForEach(VocabSortOption.allCases, id: \.rawValue) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

struct WordRow: View {
    let userWord: UserWord

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(typeColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(userWord.displayPortuguese)
                    .font(.body.weight(.semibold))
                Text(userWord.english)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(userWord.masteryScore)%")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(masteryColor)

                Text("#\(userWord.frequencyRank)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }

    private var typeColor: Color {
        switch userWord.partOfSpeech {
        case "noun": .blue
        case "verb": .orange
        case "adjective": .purple
        default: .gray
        }
    }

    private var masteryColor: Color {
        if userWord.masteryScore >= 80 { return .green }
        if userWord.masteryScore >= 50 { return .orange }
        return .red
    }
}

struct WordDetailSheet: View {
    let userWord: UserWord

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(userWord.partOfSpeech.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)

                    Text(userWord.displayPortuguese)
                        .font(.system(size: 36, weight: .bold))

                    Text(userWord.english)
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .padding(.top, 8)

                if let word = VocabularyDatabase.shared.word(byId: userWord.wordId) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("IPA: \(word.ipa)")
                            .font(.system(.callout, design: .monospaced))
                            .foregroundStyle(.secondary)

                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Example")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(word.exampleSentence)
                                .font(.body.weight(.medium))
                            Text(word.exampleTranslation)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }

                        if let conjugations = word.conjugations {
                            Divider()
                            conjugationSection(conjugations)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 16))
                }

                statsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func conjugationSection(_ conj: VerbConjugations) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conjugations")
                .font(.headline)

            conjugationTable("Present", [
                ("eu", conj.presentEu),
                ("você", conj.presentVoce),
                ("ele/ela", conj.presentEle),
                ("nós", conj.presentNos),
                ("vocês", conj.presentVoces),
            ])

            conjugationTable("Preterite", [
                ("eu", conj.preteriteEu),
                ("você", conj.preteriteVoce),
                ("ele/ela", conj.preteriteEle),
                ("nós", conj.preteriteNos),
                ("vocês", conj.preteriteVoces),
            ])

            conjugationTable("Future", [
                ("eu", conj.futureEu),
                ("você", conj.futureVoce),
                ("ele/ela", conj.futureEle),
                ("nós", conj.futureNos),
                ("vocês", conj.futureVoces),
            ])
        }
    }

    private func conjugationTable(_ tense: String, _ forms: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tense)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)

            ForEach(forms, id: \.0) { pronoun, form in
                HStack {
                    Text(pronoun)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)
                    Text(form)
                        .font(.callout.weight(.medium))
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)

            HStack(spacing: 16) {
                StatItem(label: "Mastery", value: "\(userWord.masteryScore)%")
                StatItem(label: "Tested", value: "\(userWord.timesTested)")
                StatItem(label: "Correct", value: "\(userWord.timesCorrect)")
                StatItem(label: "Accuracy", value: "\(Int(userWord.accuracy))%")
            }

            if let lastTested = userWord.lastTestedDate {
                Text("Last tested: \(lastTested.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.weight(.bold))
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
