import Foundation
import SwiftData

@Model
class UserWord {
    var wordId: String
    var portuguese: String
    var english: String
    var partOfSpeech: String
    var frequencyRank: Int
    var difficultyTier: Int
    var dateIntroduced: Date
    var lastTestedDate: Date?
    var timesTested: Int
    var timesCorrect: Int
    var timesIncorrect: Int
    var masteryScore: Int
    var reviewIntervalStage: Int
    var nextReviewDate: Date
    var isKnown: Bool
    var article: String

    var displayPortuguese: String {
        if !article.isEmpty {
            return "\(article) \(portuguese)"
        }
        return portuguese
    }

    init(
        wordId: String,
        portuguese: String,
        english: String,
        partOfSpeech: String,
        frequencyRank: Int,
        difficultyTier: Int,
        article: String = ""
    ) {
        self.wordId = wordId
        self.portuguese = portuguese
        self.english = english
        self.partOfSpeech = partOfSpeech
        self.frequencyRank = frequencyRank
        self.difficultyTier = difficultyTier
        self.dateIntroduced = Date()
        self.lastTestedDate = nil
        self.timesTested = 0
        self.timesCorrect = 0
        self.timesIncorrect = 0
        self.masteryScore = 0
        self.reviewIntervalStage = 0
        self.nextReviewDate = Date()
        self.isKnown = false
        self.article = article
    }

    var partOfSpeechEnum: PartOfSpeech {
        PartOfSpeech(rawValue: partOfSpeech) ?? .noun
    }

    var accuracy: Double {
        guard timesTested > 0 else { return 0 }
        return Double(timesCorrect) / Double(timesTested) * 100
    }
}
