import Foundation

struct VocabularyValidator {
    static let validCategories: Set<String> = [
        "greetings", "numbers", "time", "family", "body", "food", "drink",
        "clothing", "home", "city", "transportation", "travel", "shopping",
        "work", "education", "health", "emotions", "nature", "weather",
        "sports", "entertainment", "technology", "business", "legal",
        "science", "government", "culture", "religion", "slang", "phrases",
        "language"
    ]

    struct ValidationResult {
        var duplicateIds: [String] = []
        var duplicateFrequencyRanks: [Int] = []
        var irregularVerbsMissingConjugations: [String] = []
        var nounsMissingGender: [String] = []
        var nounsMissingArticle: [String] = []
        var wordsWithEmptyExamples: [String] = []
        var invalidCategories: [(String, String)] = []
        var totalWords: Int = 0

        var isValid: Bool {
            duplicateIds.isEmpty &&
            duplicateFrequencyRanks.isEmpty &&
            irregularVerbsMissingConjugations.isEmpty &&
            nounsMissingGender.isEmpty &&
            nounsMissingArticle.isEmpty &&
            wordsWithEmptyExamples.isEmpty &&
            invalidCategories.isEmpty
        }
    }

    static func validate(words: [Word]) -> ValidationResult {
        var result = ValidationResult()
        result.totalWords = words.count

        var seenIds: Set<String> = []
        var seenRanks: Set<Int> = []

        for word in words {
            if seenIds.contains(word.id) {
                result.duplicateIds.append(word.id)
            }
            seenIds.insert(word.id)

            if seenRanks.contains(word.frequencyRank) {
                result.duplicateFrequencyRanks.append(word.frequencyRank)
            }
            seenRanks.insert(word.frequencyRank)

            if word.partOfSpeech == .verb,
               word.conjugationPattern == .irregular,
               word.conjugations == nil {
                result.irregularVerbsMissingConjugations.append(word.id)
            }

            if word.partOfSpeech == .noun {
                if word.gender == nil {
                    result.nounsMissingGender.append(word.id)
                }
                if word.article == nil {
                    result.nounsMissingArticle.append(word.id)
                }
            }

            if word.exampleSentence.isEmpty || word.exampleTranslation.isEmpty {
                result.wordsWithEmptyExamples.append(word.id)
            }

            if !validCategories.contains(word.category) {
                result.invalidCategories.append((word.id, word.category))
            }
        }

        return result
    }
}
