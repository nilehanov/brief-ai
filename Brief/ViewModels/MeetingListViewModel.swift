import SwiftUI
import SwiftData

@Observable
@MainActor
final class MeetingListViewModel {
    var searchText = ""
    var selectedTemplate: TemplateType?

    func filteredMeetings(_ meetings: [Meeting]) -> [Meeting] {
        var result = meetings
        if let template = selectedTemplate {
            result = result.filter { $0.templateType == template }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.previewInsight?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        return result.sorted { $0.date > $1.date }
    }
}
