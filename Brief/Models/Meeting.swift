import Foundation
import SwiftData

enum TemplateType: String, Codable, CaseIterable, Identifiable, Sendable {
    case prep
    case debrief
    case oneOnOne
    case presentation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .prep: "Meeting Prep"
        case .debrief: "Meeting Debrief"
        case .oneOnOne: "1:1 Prep"
        case .presentation: "Presentation Prep"
        }
    }

    var icon: String {
        switch self {
        case .prep: "list.bullet.clipboard"
        case .debrief: "checkmark.circle"
        case .oneOnOne: "person.2"
        case .presentation: "rectangle.inset.filled.and.person.filled"
        }
    }

    var isPrep: Bool {
        switch self {
        case .debrief: false
        default: true
        }
    }
}

@Model
final class Meeting {
    var id: UUID
    var title: String
    var date: Date
    var inputText: String
    var templateTypeRaw: String
    @Attribute(.externalStorage) var resultJSON: Foundation.Data?
    var previewInsight: String?

    var templateType: TemplateType {
        get { TemplateType(rawValue: templateTypeRaw) ?? .prep }
        set { templateTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        inputText: String,
        templateType: TemplateType,
        resultJSON: Foundation.Data? = nil,
        previewInsight: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.inputText = inputText
        self.templateTypeRaw = templateType.rawValue
        self.resultJSON = resultJSON
        self.previewInsight = previewInsight
    }
}
