import Testing
@testable import Brief

@Test func meetingCreation() {
    let meeting = Meeting(
        title: "Test Meeting",
        inputText: "Some input text",
        templateType: .prep
    )
    #expect(meeting.title == "Test Meeting")
    #expect(meeting.templateType == .prep)
    #expect(meeting.resultJSON == nil)
}

@Test func templateTypes() {
    #expect(TemplateType.allCases.count == 4)
    #expect(TemplateType.prep.isPrep == true)
    #expect(TemplateType.debrief.isPrep == false)
    #expect(TemplateType.oneOnOne.isPrep == true)
    #expect(TemplateType.presentation.isPrep == true)
}

@Test func templateDisplayNames() {
    #expect(TemplateType.prep.displayName == "Meeting Prep")
    #expect(TemplateType.debrief.displayName == "Meeting Debrief")
    #expect(TemplateType.oneOnOne.displayName == "1:1 Prep")
    #expect(TemplateType.presentation.displayName == "Presentation Prep")
}

@Test func meetingPrepCodable() throws {
    let prep = MeetingPrep(
        talkingPoints: ["Point 1"],
        questionsToAsk: ["Question 1"],
        potentialPushback: ["Pushback 1"],
        suggestedStructure: ["Opening"],
        timeAllocation: ["5 min: Opening"]
    )
    let data = try JSONEncoder().encode(prep)
    let decoded = try JSONDecoder().decode(MeetingPrep.self, from: data)
    #expect(decoded.talkingPoints == ["Point 1"])
}
