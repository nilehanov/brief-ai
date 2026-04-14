import SwiftUI
import SwiftData

@Observable
@MainActor
final class MeetingDetailViewModel {
    let service = BriefService()

    var isGenerating: Bool { service.isGenerating }
    var error: String?
    var showingShareSheet = false
    var pdfData: Foundation.Data?

    func generate(for meeting: Meeting) async {
        error = nil
        do {
            let data = try await service.generate(for: meeting.templateType, input: meeting.inputText)
            meeting.resultJSON = data
            meeting.previewInsight = service.previewInsight(for: meeting.templateType, data: data)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func exportPDF(for meeting: Meeting) {
        pdfData = PDFExporter.exportMeeting(meeting)
        if pdfData != nil {
            showingShareSheet = true
        }
    }
}
