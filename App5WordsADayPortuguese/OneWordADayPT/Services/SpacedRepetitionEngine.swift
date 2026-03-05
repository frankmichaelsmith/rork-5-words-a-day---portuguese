import Foundation
import SwiftData

struct SpacedRepetitionEngine {
    static let reviewIntervals: [Int] = [1, 3, 7, 14, 30, 60, 120]

    static func recordCorrect(_ userWord: UserWord) {
        userWord.timesTested += 1
        userWord.timesCorrect += 1
        userWord.lastTestedDate = Date()
        userWord.masteryScore = min(100, userWord.masteryScore + 10)

        if userWord.reviewIntervalStage < reviewIntervals.count - 1 {
            userWord.reviewIntervalStage += 1
        }

        let days = reviewIntervals[userWord.reviewIntervalStage]
        userWord.nextReviewDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }

    static func recordIncorrect(_ userWord: UserWord) {
        userWord.timesTested += 1
        userWord.timesIncorrect += 1
        userWord.lastTestedDate = Date()
        userWord.masteryScore = max(0, userWord.masteryScore - 15)
        userWord.reviewIntervalStage = 0
        userWord.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

    static func wordsForReview(from userWords: [UserWord], limit: Int = 10) -> [UserWord] {
        let now = Date()
        let overdue = userWords.filter { $0.nextReviewDate <= now && !$0.isKnown }

        let sorted = overdue.sorted { a, b in
            if a.masteryScore != b.masteryScore {
                return a.masteryScore < b.masteryScore
            }
            if a.timesIncorrect != b.timesIncorrect {
                return a.timesIncorrect > b.timesIncorrect
            }
            return a.nextReviewDate < b.nextReviewDate
        }

        return Array(sorted.prefix(limit))
    }

    static func checkAccentForgiveness(_ input: String, _ expected: String) -> Bool {
        let normalize: (String) -> String = { str in
            str.lowercased()
                .folding(options: .diacriticInsensitive, locale: Locale(identifier: "pt_BR"))
                .trimmingCharacters(in: .whitespaces)
        }
        return normalize(input) == normalize(expected)
    }

    static func projectedWordsPerYear(currentPace: Double) -> Int {
        Int(currentPace * 365)
    }
}
