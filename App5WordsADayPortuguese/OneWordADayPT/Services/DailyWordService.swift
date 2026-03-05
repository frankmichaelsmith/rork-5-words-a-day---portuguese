import Foundation
import SwiftData

struct DailyWordService {
    static func dailyWords(
        learnedWordIds: Set<String>,
        difficultyTier: DifficultyTier
    ) -> (noun: Word, verb: Word, adjective: Word)? {
        let db = VocabularyDatabase.shared

        let seed = daySeed()

        let availableNouns = db.nouns(tier: difficultyTier).filter { !learnedWordIds.contains($0.id) }
        let availableVerbs = db.verbs(tier: difficultyTier).filter { !learnedWordIds.contains($0.id) }
        let availableAdjectives = db.adjectives(tier: difficultyTier).filter { !learnedWordIds.contains($0.id) }

        guard !availableNouns.isEmpty, !availableVerbs.isEmpty, !availableAdjectives.isEmpty else {
            return nil
        }

        let nounIndex = abs(seed.hashValue) % availableNouns.count
        let verbIndex = abs((seed + "verb").hashValue) % availableVerbs.count
        let adjIndex = abs((seed + "adj").hashValue) % availableAdjectives.count

        return (
            noun: availableNouns[nounIndex],
            verb: availableVerbs[verbIndex],
            adjective: availableAdjectives[adjIndex]
        )
    }

    static func replacementWord(
        partOfSpeech: PartOfSpeech,
        learnedWordIds: Set<String>,
        excludeIds: Set<String>,
        difficultyTier: DifficultyTier
    ) -> Word? {
        let db = VocabularyDatabase.shared
        let allExcluded = learnedWordIds.union(excludeIds)

        let available: [Word]
        switch partOfSpeech {
        case .noun:
            available = db.nouns(tier: difficultyTier).filter { !allExcluded.contains($0.id) }
        case .verb:
            available = db.verbs(tier: difficultyTier).filter { !allExcluded.contains($0.id) }
        case .adjective:
            available = db.adjectives(tier: difficultyTier).filter { !allExcluded.contains($0.id) }
        }

        return available.randomElement()
    }

    private static func daySeed() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
