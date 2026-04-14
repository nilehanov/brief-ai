import Foundation
import FoundationModels

@Observable
@MainActor
final class BriefService {

    enum BriefError: LocalizedError {
        case aiUnavailable
        case generationFailed(String)

        var errorDescription: String? {
            switch self {
            case .aiUnavailable:
                "Apple Intelligence is not available on this device."
            case .generationFailed(let msg):
                "Generation failed: \(msg)"
            }
        }
    }

    var isGenerating = false

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    func generatePrep(from input: String) async throws -> MeetingPrep {
        guard Self.isAvailable else { throw BriefError.aiUnavailable }
        isGenerating = true
        defer { isGenerating = false }

        let session = LanguageModelSession(instructions: """
        You are a professional meeting preparation assistant. \
        Analyze the provided meeting context and generate structured preparation materials. \
        Be specific, actionable, and concise.
        """)
        let response = try await session.respond(
            to: "Prepare for this meeting:\n\n\(input)",
            generating: MeetingPrep.self
        )
        return response.content
    }

    func generateDebrief(from input: String) async throws -> MeetingDebrief {
        guard Self.isAvailable else { throw BriefError.aiUnavailable }
        isGenerating = true
        defer { isGenerating = false }

        let session = LanguageModelSession(instructions: """
        You are a professional meeting debrief assistant. \
        Analyze the meeting notes and extract key decisions, action items, open questions, \
        and draft a follow-up email. Be precise about owners and deadlines.
        """)
        let response = try await session.respond(
            to: "Debrief these meeting notes:\n\n\(input)",
            generating: MeetingDebrief.self
        )
        return response.content
    }

    func generateOneOnOne(from input: String) async throws -> OneOnOnePrep {
        guard Self.isAvailable else { throw BriefError.aiUnavailable }
        isGenerating = true
        defer { isGenerating = false }

        let session = LanguageModelSession(instructions: """
        You are a professional 1:1 meeting preparation assistant. \
        Generate thoughtful conversation starters, topics, and follow-up points \
        for a productive one-on-one meeting.
        """)
        let response = try await session.respond(
            to: "Prepare for this 1:1 meeting:\n\n\(input)",
            generating: OneOnOnePrep.self
        )
        return response.content
    }

    func generatePresentation(from input: String) async throws -> PresentationPrep {
        guard Self.isAvailable else { throw BriefError.aiUnavailable }
        isGenerating = true
        defer { isGenerating = false }

        let session = LanguageModelSession(instructions: """
        You are a professional presentation coach. \
        Generate key messages, anticipated questions, a strong opening hook, \
        and suggested slide structure for the presentation topic.
        """)
        let response = try await session.respond(
            to: "Prepare for this presentation:\n\n\(input)",
            generating: PresentationPrep.self
        )
        return response.content
    }

    func generate(for templateType: TemplateType, input: String) async throws -> Foundation.Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        switch templateType {
        case .prep:
            let result = try await generatePrep(from: input)
            return try encoder.encode(result)
        case .debrief:
            let result = try await generateDebrief(from: input)
            return try encoder.encode(result)
        case .oneOnOne:
            let result = try await generateOneOnOne(from: input)
            return try encoder.encode(result)
        case .presentation:
            let result = try await generatePresentation(from: input)
            return try encoder.encode(result)
        }
    }

    func previewInsight(for templateType: TemplateType, data: Foundation.Data) -> String? {
        let decoder = JSONDecoder()
        switch templateType {
        case .prep:
            guard let result = try? decoder.decode(MeetingPrep.self, from: data) else { return nil }
            return "\(result.talkingPoints.count) talking points, \(result.questionsToAsk.count) questions"
        case .debrief:
            guard let result = try? decoder.decode(MeetingDebrief.self, from: data) else { return nil }
            return "\(result.decisions.count) decisions, \(result.actionItems.count) action items"
        case .oneOnOne:
            guard let result = try? decoder.decode(OneOnOnePrep.self, from: data) else { return nil }
            return "\(result.topicsToCover.count) topics, \(result.questions.count) questions"
        case .presentation:
            guard let result = try? decoder.decode(PresentationPrep.self, from: data) else { return nil }
            return "\(result.keyMessages.count) key messages, \(result.slideStructure.count) slides"
        }
    }
}
