import SwiftUI

struct FlashcardView: View {
    let word: Word
    let isFlipped: Bool
    let onFlip: () -> Void
    let onLearn: () -> Void
    let onKnown: () -> Void

    @State private var flipTrigger: Bool = false
    @State private var learnTrigger: Bool = false
    @State private var knownTrigger: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            cardContent
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)

            if isFlipped {
                actionButtons
                    .padding(.top, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.3), value: isFlipped)
        .sensoryFeedback(.impact(weight: .light), trigger: flipTrigger)
        .sensoryFeedback(.success, trigger: learnTrigger)
        .sensoryFeedback(.impact(weight: .medium), trigger: knownTrigger)
    }

    @ViewBuilder
    private var cardContent: some View {
        if isFlipped {
            flippedContent
        } else {
            frontContent
        }
    }

    private var frontContent: some View {
        VStack(spacing: 16) {
            partOfSpeechBadge

            Text(word.displayPortuguese)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.primary)

            Text(word.ipa)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)

            Spacer().frame(height: 8)

            Button {
                flipTrigger.toggle()
                onFlip()
            } label: {
                Text("Tap to reveal")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.quaternary, in: Capsule())
            }
        }
        .padding(.vertical, 20)
    }

    private var flippedContent: some View {
        VStack(spacing: 16) {
            partOfSpeechBadge

            Text(word.english)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)

            Text(word.displayPortuguese)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.blue)

            Text(word.ipa)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.tertiary)

            Divider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(word.exampleSentence)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                Text(word.exampleTranslation)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if word.partOfSpeech == .verb, let conjugations = word.conjugations {
                Divider()
                    .padding(.vertical, 4)
                conjugationSection(conjugations)
            }

            HStack(spacing: 16) {
                Label("Rank #\(word.frequencyRank)", systemImage: "chart.bar.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label("Tier \(word.difficultyTier.rawValue)", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 12)
    }

    private func conjugationSection(_ conj: VerbConjugations) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CONJUGATIONS")
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.orange)

            conjugationTenseRow("Present", [
                ("eu", conj.presentEu, "I"),
                ("você", conj.presentVoce, "you"),
                ("nós", conj.presentNos, "we"),
            ])

            conjugationTenseRow("Past", [
                ("eu", conj.preteriteEu, "I"),
                ("você", conj.preteriteVoce, "you"),
                ("nós", conj.preteriteNos, "we"),
            ])

            conjugationTenseRow("Future", [
                ("eu", conj.futureEu, "I"),
                ("você", conj.futureVoce, "you"),
                ("nós", conj.futureNos, "we"),
            ])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func conjugationTenseRow(_ tense: String, _ forms: [(String, String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tense)
                .font(.caption.weight(.bold))
                .foregroundStyle(.blue)

            ForEach(forms, id: \.0) { pronoun, form, englishPronoun in
                HStack(spacing: 0) {
                    Text(pronoun)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, alignment: .leading)
                    Text(form)
                        .font(.callout.weight(.semibold))
                    Spacer()
                    Text("(\(englishPronoun))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private var partOfSpeechBadge: some View {
        Text(word.partOfSpeech.rawValue.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(1.2)
            .foregroundStyle(badgeColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.12), in: Capsule())
    }

    private var badgeColor: Color {
        switch word.partOfSpeech {
        case .noun: .blue
        case .verb: .orange
        case .adjective: .purple
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                knownTrigger.toggle()
                onKnown()
            } label: {
                Label("Already Know", systemImage: "arrow.uturn.right")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 14))
            }
            .tint(.secondary)

            Button {
                learnTrigger.toggle()
                onLearn()
            } label: {
                Label("Learn", systemImage: "checkmark")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 14))
            }
        }
    }
}
