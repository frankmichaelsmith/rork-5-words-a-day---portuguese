import Foundation

struct ConjugationEngine {
    static func conjugations(for word: Word) -> VerbConjugations? {
        if let explicit = word.conjugations {
            return explicit
        }

        guard word.partOfSpeech == .verb,
              let pattern = word.conjugationPattern,
              pattern != .irregular else {
            return nil
        }

        return generateConjugations(infinitive: word.portuguese, pattern: pattern)
    }

    static func generateConjugations(infinitive: String, pattern: ConjugationPattern) -> VerbConjugations? {
        let stem: String
        switch pattern {
        case .regularAR:
            guard infinitive.hasSuffix("ar") else { return nil }
            stem = String(infinitive.dropLast(2))
        case .regularER:
            guard infinitive.hasSuffix("er") else { return nil }
            stem = String(infinitive.dropLast(2))
        case .regularIR:
            guard infinitive.hasSuffix("ir") else { return nil }
            stem = String(infinitive.dropLast(2))
        case .irregular:
            return nil
        }

        switch pattern {
        case .regularAR:
            return VerbConjugations(
                infinitive: infinitive,
                presentEu: stem + "o",
                presentVoce: stem + "a",
                presentEle: stem + "a",
                presentNos: stem + "amos",
                presentVoces: stem + "am",
                preteriteEu: stem + "ei",
                preteriteVoce: stem + "ou",
                preteriteEle: stem + "ou",
                preteriteNos: stem + "amos",
                preteriteVoces: stem + "aram",
                futureEu: infinitive + "ei",
                futureVoce: infinitive + "á",
                futureEle: infinitive + "á",
                futureNos: infinitive + "emos",
                futureVoces: infinitive + "ão"
            )
        case .regularER:
            return VerbConjugations(
                infinitive: infinitive,
                presentEu: stem + "o",
                presentVoce: stem + "e",
                presentEle: stem + "e",
                presentNos: stem + "emos",
                presentVoces: stem + "em",
                preteriteEu: stem + "i",
                preteriteVoce: stem + "eu",
                preteriteEle: stem + "eu",
                preteriteNos: stem + "emos",
                preteriteVoces: stem + "eram",
                futureEu: infinitive + "ei",
                futureVoce: infinitive + "á",
                futureEle: infinitive + "á",
                futureNos: infinitive + "emos",
                futureVoces: infinitive + "ão"
            )
        case .regularIR:
            return VerbConjugations(
                infinitive: infinitive,
                presentEu: stem + "o",
                presentVoce: stem + "e",
                presentEle: stem + "e",
                presentNos: stem + "imos",
                presentVoces: stem + "em",
                preteriteEu: stem + "i",
                preteriteVoce: stem + "iu",
                preteriteEle: stem + "iu",
                preteriteNos: stem + "imos",
                preteriteVoces: stem + "iram",
                futureEu: infinitive + "ei",
                futureVoce: infinitive + "á",
                futureEle: infinitive + "á",
                futureNos: infinitive + "emos",
                futureVoces: infinitive + "ão"
            )
        case .irregular:
            return nil
        }
    }
}
