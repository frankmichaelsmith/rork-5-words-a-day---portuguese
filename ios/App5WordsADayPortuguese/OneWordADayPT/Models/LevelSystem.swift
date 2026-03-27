import Foundation

nonisolated enum ProficiencyLevel: Int, CaseIterable, Sendable {
    case survival = 1
    case conversational = 2
    case functional = 3
    case professional = 4
    case native = 5

    var name: String {
        switch self {
        case .survival: "Survival"
        case .conversational: "Conversational"
        case .functional: "Functional"
        case .professional: "Professional"
        case .native: "Native"
        }
    }

    var wordThreshold: Int {
        switch self {
        case .survival: 0
        case .conversational: 1_000
        case .functional: 2_500
        case .professional: 5_000
        case .native: 10_000
        }
    }

    var nextLevelThreshold: Int {
        switch self {
        case .survival: 1_000
        case .conversational: 2_500
        case .functional: 5_000
        case .professional: 10_000
        case .native: 20_000
        }
    }

    var icon: String {
        switch self {
        case .survival: "figure.walk"
        case .conversational: "bubble.left.and.bubble.right.fill"
        case .functional: "briefcase.fill"
        case .professional: "graduationcap.fill"
        case .native: "crown.fill"
        }
    }

    var description: String {
        switch self {
        case .survival: "Understand ~75% of daily text. Handle ordering food, asking directions."
        case .conversational: "Express almost anything, even with workarounds for unknown words."
        case .functional: "Understand 98% of ordinary text. Guess new words from context."
        case .professional: "High precision expression. Read complex academic materials."
        case .native: "Understand nuance, obscure metaphors, and specialized literature."
        }
    }

    static func level(for wordCount: Int) -> ProficiencyLevel {
        if wordCount >= 10_000 { return .native }
        if wordCount >= 5_000 { return .professional }
        if wordCount >= 2_500 { return .functional }
        if wordCount >= 1_000 { return .conversational }
        return .survival
    }

    static func progress(for wordCount: Int) -> Double {
        let level = level(for: wordCount)
        let start = level.wordThreshold
        let end = level.nextLevelThreshold
        let range = end - start
        guard range > 0 else { return 1.0 }
        return min(1.0, Double(wordCount - start) / Double(range))
    }

    var next: ProficiencyLevel? {
        ProficiencyLevel(rawValue: rawValue + 1)
    }
}
