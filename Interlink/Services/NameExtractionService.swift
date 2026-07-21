import Foundation
import NaturalLanguage

struct ExtractedNameCandidate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let suggestedType: EntityType
}

struct NameExtractionService {
    static func extractNames(from text: String) -> [ExtractedNameCandidate] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = trimmed

        var candidates: [ExtractedNameCandidate] = []
        var seenNames = Set<String>()

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]

        tagger.enumerateTags(in: trimmed.startIndex..<trimmed.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
                let rawName = String(trimmed[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                let normalized = rawName.lowercased()

                if rawName.count > 1 && !seenNames.contains(normalized) {
                    seenNames.insert(normalized)

                    let suggestedType: EntityType
                    switch tag {
                    case .personalName:
                        suggestedType = .person
                    case .placeName:
                        suggestedType = .place
                    case .organizationName:
                        suggestedType = .project
                    default:
                        suggestedType = .concept
                    }

                    candidates.append(ExtractedNameCandidate(name: rawName, suggestedType: suggestedType))
                }
            }
            return true
        }

        return candidates
    }
}
