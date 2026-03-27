import Foundation

nonisolated enum PartOfSpeech: String, Codable, Sendable, CaseIterable {
    case noun
    case verb
    case adjective
    case adverb
    case preposition
    case conjunction
    case pronoun
    case phrase
}

nonisolated enum DifficultyTier: Int, Codable, Sendable, Comparable, CaseIterable {
    case beginner = 1
    case elementary = 2
    case intermediate = 3
    case upperIntermediate = 4
    case advanced = 5

    nonisolated static func < (lhs: DifficultyTier, rhs: DifficultyTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

nonisolated enum ConjugationPattern: String, Codable, Sendable {
    case regularAR
    case regularER
    case regularIR
    case irregular
}

nonisolated struct Word: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let portuguese: String
    let english: String
    let ipa: String
    let partOfSpeech: PartOfSpeech
    let exampleSentence: String
    let exampleTranslation: String
    let frequencyRank: Int
    let difficultyTier: DifficultyTier
    let conjugations: VerbConjugations?
    let article: String?
    let category: String
    let plural: String?
    let gender: String?
    let synonyms: [String]?
    let notes: String?
    let conjugationPattern: ConjugationPattern?

    var displayPortuguese: String {
        if let article {
            return "\(article) \(portuguese)"
        }
        return portuguese
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id
    }
}

nonisolated struct VerbConjugations: Codable, Sendable {
    let infinitive: String
    let presentEu: String
    let presentVoce: String
    let presentEle: String
    let presentNos: String
    let presentVoces: String
    let preteriteEu: String
    let preteriteVoce: String
    let preteriteEle: String
    let preteriteNos: String
    let preteriteVoces: String
    let futureEu: String
    let futureVoce: String
    let futureEle: String
    let futureNos: String
    let futureVoces: String
}
