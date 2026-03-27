import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
class AppViewModel {
    private let modelContext: ModelContext

    var dailyWords: [Word] = []
    var currentCardIndex: Int = 0
    var reviewWords: [UserWord] = []
    var isFlipped: Bool = false
    var showCompletionMessage: Bool = false
    var todayCompleted: Bool = false
    var sessionNumber: Int = 1
    var wordsLearnedToday: Int = 0
    private var forceNewSession: Bool = false
    private var wordsDirtyCounter: Int = 0

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        ensureSettings()
        loadDailyWords()
        checkStreak()
    }

    private var settings: UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        return results.first ?? UserSettings()
    }

    private func ensureSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        if results.isEmpty {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
        }
    }

    var currentStreak: Int { settings.currentStreak }
    var longestStreak: Int { settings.longestStreak }
    var totalWordsLearned: Int { settings.totalWordsLearned }

    var allUserWords: [UserWord] {
        _ = wordsDirtyCounter
        var descriptor = FetchDescriptor<UserWord>()
        descriptor.sortBy = [SortDescriptor(\UserWord.masteryScore, order: .reverse)]
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var overallMastery: Double {
        let words = allUserWords
        guard !words.isEmpty else { return 0 }
        return Double(words.reduce(0) { $0 + $1.masteryScore }) / Double(words.count)
    }

    var currentLevel: ProficiencyLevel {
        ProficiencyLevel.level(for: totalWordsLearned)
    }

    var levelProgress: Double {
        ProficiencyLevel.progress(for: totalWordsLearned)
    }

    var wordsToNextLevel: Int {
        let next = currentLevel.nextLevelThreshold
        return max(0, next - totalWordsLearned)
    }

    var countByPartOfSpeech: [(String, Int)] {
        let words = allUserWords
        let grouped = Dictionary(grouping: words) { $0.partOfSpeech }
        return PartOfSpeech.allCases.compactMap { pos in
            let count = grouped[pos.rawValue]?.count ?? 0
            guard count > 0 else { return nil }
            return (pos.rawValue.capitalized, count)
        }
    }

    var reviewCount: Int {
        SpacedRepetitionEngine.wordsForReview(from: allUserWords).count
    }

    var currentDifficultyTier: DifficultyTier {
        DifficultyTier(rawValue: settings.currentDifficultyTier) ?? .beginner
    }

    func loadDailyWords() {
        let learnedIds = Set(allUserWords.map(\.wordId))

        let todaySeed = todayDateString()
        if settings.dailyWordsSeed == todaySeed && !forceNewSession {
            todayCompleted = true
        } else {
            let words = fetchSessionWords(count: 5, learnedIds: learnedIds, excludeIds: [])
            dailyWords = words
            todayCompleted = words.isEmpty
        }

        currentCardIndex = 0
        isFlipped = false
        showCompletionMessage = false
        forceNewSession = false
    }

    private func fetchSessionWords(count: Int, learnedIds: Set<String>, excludeIds: Set<String>) -> [Word] {
        var words: [Word] = []
        var excluded = excludeIds
        let partOfSpeeches: [PartOfSpeech] = [.noun, .verb, .adjective, .noun, .verb]

        for i in 0..<count {
            let pos = partOfSpeeches[i % partOfSpeeches.count]
            if let word = DailyWordService.replacementWord(
                partOfSpeech: pos,
                learnedWordIds: learnedIds,
                excludeIds: excluded,
                difficultyTier: currentDifficultyTier
            ) {
                words.append(word)
                excluded.insert(word.id)
            }
        }
        return words
    }

    var canStartAnotherSession: Bool {
        sessionNumber < 3
    }

    func startAnotherSession() {
        guard canStartAnotherSession else { return }
        sessionNumber += 1
        forceNewSession = true
        todayCompleted = false
        showCompletionMessage = false
        let learnedIds = Set(allUserWords.map(\.wordId))
        let excludeIds = Set(dailyWords.map(\.id))

        let newWords = fetchSessionWords(count: 5, learnedIds: learnedIds, excludeIds: excludeIds)

        if !newWords.isEmpty {
            dailyWords = newWords
            currentCardIndex = 0
            isFlipped = false
        }
    }

    func learnWord(_ word: Word) {
        let userWord = UserWord(
            wordId: word.id,
            portuguese: word.portuguese,
            english: word.english,
            partOfSpeech: word.partOfSpeech.rawValue,
            frequencyRank: word.frequencyRank,
            difficultyTier: word.difficultyTier.rawValue,
            article: word.article ?? ""
        )
        modelContext.insert(userWord)
        try? modelContext.save()

        let s = settings
        s.totalWordsLearned += 1
        wordsLearnedToday += 1
        wordsDirtyCounter += 1

        advanceCard()
    }

    func markKnown(_ word: Word) {
        let userWord = UserWord(
            wordId: word.id,
            portuguese: word.portuguese,
            english: word.english,
            partOfSpeech: word.partOfSpeech.rawValue,
            frequencyRank: word.frequencyRank,
            difficultyTier: word.difficultyTier.rawValue,
            article: word.article ?? ""
        )
        userWord.isKnown = true
        userWord.masteryScore = 90
        userWord.reviewIntervalStage = 5
        userWord.nextReviewDate = Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date()
        modelContext.insert(userWord)
        try? modelContext.save()

        let s = settings
        s.totalWordsLearned += 1
        wordsLearnedToday += 1
        wordsDirtyCounter += 1

        let learnedIds = Set(allUserWords.map(\.wordId))
        if let replacement = DailyWordService.replacementWord(
            partOfSpeech: word.partOfSpeech,
            learnedWordIds: learnedIds,
            excludeIds: Set(dailyWords.map(\.id)),
            difficultyTier: currentDifficultyTier
        ) {
            if currentCardIndex < dailyWords.count {
                dailyWords[currentCardIndex] = replacement
            }
        } else {
            advanceCard()
        }

        isFlipped = false
    }

    private func advanceCard() {
        isFlipped = false
        if currentCardIndex < dailyWords.count - 1 {
            currentCardIndex += 1
        } else {
            completeDailySession()
        }
    }

    private func completeDailySession() {
        showCompletionMessage = true
        todayCompleted = true

        let s = settings
        s.dailyWordsSeed = todayDateString()

        updateStreak()

        let session = StudySession(
            wordsStudied: dailyWords.count,
            wordsCorrect: dailyWords.count,
            sessionType: "daily"
        )
        modelContext.insert(session)
    }

    func loadReviewWords() {
        reviewWords = SpacedRepetitionEngine.wordsForReview(from: allUserWords)
    }

    func reviewCorrect(_ userWord: UserWord) {
        SpacedRepetitionEngine.recordCorrect(userWord)
    }

    func reviewIncorrect(_ userWord: UserWord) {
        SpacedRepetitionEngine.recordIncorrect(userWord)
    }

    func checkRecallAnswer(_ input: String, expected: String) -> Bool {
        SpacedRepetitionEngine.checkAccentForgiveness(input, expected)
    }

    private func checkStreak() {
        guard let lastDate = settings.lastStudyDate else { return }
        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: Date())).day ?? 0
        if daysSince > 1 {
            settings.currentStreak = 0
        }
    }

    private func updateStreak() {
        let s = settings
        let calendar = Calendar.current

        if let lastDate = s.lastStudyDate {
            let daysSince = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: Date())).day ?? 0
            if daysSince == 1 {
                s.currentStreak += 1
            } else if daysSince > 1 {
                s.currentStreak = 1
            }
        } else {
            s.currentStreak = 1
        }

        s.longestStreak = max(s.longestStreak, s.currentStreak)
        s.lastStudyDate = Date()

        adaptDifficulty()
    }

    private func adaptDifficulty() {
        let recentSessions = recentStudySessions(days: 7)
        guard !recentSessions.isEmpty else { return }

        let totalStudied = recentSessions.reduce(0) { $0 + $1.wordsStudied }
        let totalCorrect = recentSessions.reduce(0) { $0 + $1.wordsCorrect }
        guard totalStudied > 0 else { return }

        let weeklyAccuracy = Double(totalCorrect) / Double(totalStudied) * 100
        let s = settings

        if weeklyAccuracy > 85 && s.currentDifficultyTier < 5 {
            s.currentDifficultyTier += 1
        } else if weeklyAccuracy < 60 && s.currentDifficultyTier > 1 {
            s.currentDifficultyTier -= 1
        }
    }

    func recentStudySessions(days: Int) -> [StudySession] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { $0.date >= startDate },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func studySessionsForCalendar() -> [Date: Int] {
        let startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<StudySession>(
            predicate: #Predicate { $0.date >= startDate }
        )
        let sessions = (try? modelContext.fetch(descriptor)) ?? []

        var calendar: [Date: Int] = [:]
        let cal = Calendar.current
        for session in sessions {
            let day = cal.startOfDay(for: session.date)
            calendar[day, default: 0] += session.wordsStudied
        }
        return calendar
    }

    var weeklyAccuracy: Double {
        let sessions = recentStudySessions(days: 7)
        let totalStudied = sessions.reduce(0) { $0 + $1.wordsStudied }
        let totalCorrect = sessions.reduce(0) { $0 + $1.wordsCorrect }
        guard totalStudied > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalStudied) * 100
    }

    var projectedYearlyWords: Int {
        let sessions = recentStudySessions(days: 30)
        let totalDays = max(1, sessions.count)
        let totalWords = sessions.reduce(0) { $0 + $1.wordsStudied }
        let dailyPace = Double(totalWords) / Double(totalDays)
        return SpacedRepetitionEngine.projectedWordsPerYear(currentPace: max(dailyPace, 3))
    }

    var masteryByPartOfSpeech: [(String, Double)] {
        let words = allUserWords
        let grouped = Dictionary(grouping: words) { $0.partOfSpeech }
        return grouped.map { key, values in
            let avg = Double(values.reduce(0) { $0 + $1.masteryScore }) / Double(values.count)
            return (key.capitalized, avg)
        }.sorted { $0.0 < $1.0 }
    }

    func conjugationChallenge() -> (userWord: UserWord, pronoun: String, tense: String, answer: String)? {
        let verbs = allUserWords.filter { $0.partOfSpeech == "verb" && !$0.isKnown && $0.masteryScore < 90 }
        guard let userWord = verbs.randomElement(),
              let word = VocabularyDatabase.shared.word(byId: userWord.wordId) else { return nil }

        let conj: VerbConjugations?
        if let explicit = word.conjugations {
            conj = explicit
        } else {
            conj = ConjugationEngine.conjugations(for: word)
        }

        guard let conj else { return nil }

        let pronouns = ["eu", "você", "ele/ela", "nós", "vocês"]
        let tenses: [(String, [String])] = [
            ("Present", [conj.presentEu, conj.presentVoce, conj.presentEle, conj.presentNos, conj.presentVoces]),
            ("Preterite", [conj.preteriteEu, conj.preteriteVoce, conj.preteriteEle, conj.preteriteNos, conj.preteriteVoces]),
            ("Future", [conj.futureEu, conj.futureVoce, conj.futureEle, conj.futureNos, conj.futureVoces])
        ]

        let tenseIndex = Int.random(in: 0..<tenses.count)
        let pronounIndex = Int.random(in: 0..<pronouns.count)

        return (userWord, pronouns[pronounIndex], tenses[tenseIndex].0, tenses[tenseIndex].1[pronounIndex])
    }

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
