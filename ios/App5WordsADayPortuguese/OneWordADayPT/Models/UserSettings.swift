import Foundation
import SwiftData

@Model
class UserSettings {
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date?
    var totalWordsLearned: Int
    var currentDifficultyTier: Int
    var dailyWordsSeed: String
    var onboardingCompleted: Bool

    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastStudyDate = nil
        self.totalWordsLearned = 0
        self.currentDifficultyTier = 1
        self.dailyWordsSeed = ""
        self.onboardingCompleted = false
    }
}
