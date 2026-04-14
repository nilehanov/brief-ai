import SwiftUI
import SwiftData

@main
struct BriefApp: App {
    var body: some Scene {
        WindowGroup {
            MeetingListView()
        }
        .modelContainer(for: Meeting.self)
    }
}
