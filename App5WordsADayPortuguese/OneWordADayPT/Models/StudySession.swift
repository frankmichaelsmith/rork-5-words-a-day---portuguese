import Foundation
import SwiftData

@Model
class StudySession {
    var date: Date
    var wordsStudied: Int
    var wordsCorrect: Int
    var sessionType: String

    init(date: Date = Date(), wordsStudied: Int = 0, wordsCorrect: Int = 0, sessionType: String = "daily") {
        self.date = date
        self.wordsStudied = wordsStudied
        self.wordsCorrect = wordsCorrect
        self.sessionType = sessionType
    }

    var accuracy: Double {
        guard wordsStudied > 0 else { return 0 }
        return Double(wordsCorrect) / Double(wordsStudied) * 100
    }
}
