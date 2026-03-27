import Foundation

struct DailyWordService {
    static func dailyWords(
        learnedWordIds: Set<String>,
        difficultyTier: DifficultyTier
    ) -> [Word] {
        let db = VocabularyDatabase.shared
        db.ensureTiersLoaded(through: difficultyTier)

        let available = db.words(tier: difficultyTier).filter { !learnedWordIds.contains($0.id) }
        guard !available.isEmpty else { return [] }

        let seed = daySeed()
        var selected: [Word] = []
        var usedIds: Set<String> = []

        let targetPOS: [PartOfSpeech] = [.noun, .verb, .adjective, .noun, .verb]

        for (i, pos) in targetPOS.enumerated() {
            let posAvailable = available.filter { $0.partOfSpeech == pos && !usedIds.contains($0.id) }
            if !posAvailable.isEmpty {
                let index = abs((seed + "\(pos.rawValue)\(i)").hashValue) % posAvailable.count
                let word = posAvailable[index]
                selected.append(word)
                usedIds.insert(word.id)
            }
        }

        return selected
    }

    static func replacementWord(
        partOfSpeech: PartOfSpeech,
        learnedWordIds: Set<String>,
        excludeIds: Set<String>,
        difficultyTier: DifficultyTier
    ) -> Word? {
        let db = VocabularyDatabase.shared
        db.ensureTiersLoaded(through: difficultyTier)

        let allExcluded = learnedWordIds.union(excludeIds)
        let available = db.words(partOfSpeech: partOfSpeech, tier: difficultyTier)
            .filter { !allExcluded.contains($0.id) }

        return available.randomElement()
    }

    private static func daySeed() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
