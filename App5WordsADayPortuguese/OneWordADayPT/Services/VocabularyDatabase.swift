import Foundation

@MainActor
class VocabularyDatabase {
    static let shared = VocabularyDatabase()

    private var wordIndex: [String: Word] = [:]
    private var loadedTiers: Set<DifficultyTier> = []
    private var cachedWords: [Word]?

    var words: [Word] {
        if let cachedWords { return cachedWords }
        let result = Array(wordIndex.values)
        cachedWords = result
        return result
    }

    private init() {
        loadTier(.beginner)
        loadTier(.elementary)
    }

    private static let tierFiles: [DifficultyTier: String] = [
        .beginner: "vocabulary_tier1_beginner",
        .elementary: "vocabulary_tier2_elementary",
        .intermediate: "vocabulary_tier3_intermediate",
        .upperIntermediate: "vocabulary_tier4_upper_intermediate",
        .advanced: "vocabulary_tier5_advanced"
    ]

    func ensureTiersLoaded(through tier: DifficultyTier) {
        for t in DifficultyTier.allCases where t.rawValue <= tier.rawValue {
            loadTier(t)
        }
    }

    private func loadTier(_ tier: DifficultyTier) {
        guard !loadedTiers.contains(tier),
              let fileName = Self.tierFiles[tier] else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }

        let decoder = JSONDecoder()
        guard let loadedWords = try? decoder.decode([Word].self, from: data) else { return }

        let enrichedWords = loadedWords.map { word -> Word in
            if word.partOfSpeech == .verb && word.conjugations == nil,
               let pattern = word.conjugationPattern,
               pattern != .irregular,
               let generated = ConjugationEngine.generateConjugations(infinitive: word.portuguese, pattern: pattern) {
                return Word(
                    id: word.id,
                    portuguese: word.portuguese,
                    english: word.english,
                    ipa: word.ipa,
                    partOfSpeech: word.partOfSpeech,
                    exampleSentence: word.exampleSentence,
                    exampleTranslation: word.exampleTranslation,
                    frequencyRank: word.frequencyRank,
                    difficultyTier: word.difficultyTier,
                    conjugations: generated,
                    article: word.article,
                    category: word.category,
                    plural: word.plural,
                    gender: word.gender,
                    synonyms: word.synonyms,
                    notes: word.notes,
                    conjugationPattern: word.conjugationPattern
                )
            }
            return word
        }

        for word in enrichedWords {
            wordIndex[word.id] = word
        }
        cachedWords = nil
        loadedTiers.insert(tier)
    }

    func words(partOfSpeech: PartOfSpeech? = nil, tier: DifficultyTier? = nil) -> [Word] {
        if let tier {
            ensureTiersLoaded(through: tier)
        }

        var result = words

        if let partOfSpeech {
            result = result.filter { $0.partOfSpeech == partOfSpeech }
        }

        if let tier {
            result = result.filter { $0.difficultyTier <= tier }
        }

        return result
    }

    func nouns(tier: DifficultyTier? = nil) -> [Word] {
        words(partOfSpeech: .noun, tier: tier)
    }

    func verbs(tier: DifficultyTier? = nil) -> [Word] {
        words(partOfSpeech: .verb, tier: tier)
    }

    func adjectives(tier: DifficultyTier? = nil) -> [Word] {
        words(partOfSpeech: .adjective, tier: tier)
    }

    func word(byId id: String) -> Word? {
        wordIndex[id]
    }

    var totalWordCount: Int {
        for tier in DifficultyTier.allCases {
            loadTier(tier)
        }
        return wordIndex.count
    }
}
