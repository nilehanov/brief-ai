import Foundation
import FoundationModels

@Generable
struct MeetingPrep: Codable, Sendable {
    @Guide(description: "Key talking points to raise")
    var talkingPoints: [String]

    @Guide(description: "Questions to ask during the meeting")
    var questionsToAsk: [String]

    @Guide(description: "Potential objections or pushback to anticipate")
    var potentialPushback: [String]

    @Guide(description: "Suggested meeting structure or agenda flow")
    var suggestedStructure: [String]

    @Guide(description: "Recommended time allocation per topic in minutes")
    var timeAllocation: [String]
}

@Generable
struct ActionItem: Codable, Sendable {
    @Guide(description: "The task")
    var task: String

    @Guide(description: "Person responsible")
    var owner: String

    @Guide(description: "Deadline if mentioned")
    var deadline: String
}

@Generable
struct MeetingDebrief: Codable, Sendable {
    @Guide(description: "Key decisions that were made")
    var decisions: [String]

    @Guide(description: "Action items with responsible person")
    var actionItems: [ActionItem]

    @Guide(description: "Questions that remain open or unresolved")
    var openQuestions: [String]

    @Guide(description: "Brief follow-up email text to send to attendees")
    var followUpEmail: String
}

@Generable
struct OneOnOnePrep: Codable, Sendable {
    @Guide(description: "Conversation starters")
    var starters: [String]

    @Guide(description: "Topics to cover")
    var topicsToCover: [String]

    @Guide(description: "Questions to ask")
    var questions: [String]

    @Guide(description: "Points to follow up on from previous conversations")
    var followUps: [String]
}

@Generable
struct PresentationPrep: Codable, Sendable {
    @Guide(description: "Key messages to communicate")
    var keyMessages: [String]

    @Guide(description: "Questions the audience might ask")
    var anticipatedQuestions: [String]

    @Guide(description: "Strong opening hook or statement")
    var openingHook: String

    @Guide(description: "Suggested slide structure")
    var slideStructure: [String]
}
