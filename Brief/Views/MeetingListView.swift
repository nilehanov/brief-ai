import SwiftUI
import SwiftData

struct MeetingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meeting.date, order: .reverse) private var meetings: [Meeting]
    @State private var viewModel = MeetingListViewModel()
    @State private var showingNewMeeting = false

    var body: some View {
        NavigationStack {
            Group {
                if meetings.isEmpty {
                    emptyState
                } else {
                    meetingList
                }
            }
            .navigationTitle("Brief")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewMeeting = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.briefAccent)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search meetings...")
            .sheet(isPresented: $showingNewMeeting) {
                NewMeetingView()
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Meetings Yet", systemImage: "briefcase")
        } description: {
            Text("Tap + to prepare for a meeting or debrief after one.")
        } actions: {
            Button("New Meeting") {
                showingNewMeeting = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.briefAccent)
        }
    }

    private var meetingList: some View {
        List {
            templateFilter

            ForEach(viewModel.filteredMeetings(meetings)) { meeting in
                NavigationLink(value: meeting) {
                    MeetingRow(meeting: meeting)
                }
            }
            .onDelete(perform: deleteMeetings)
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Meeting.self) { meeting in
            MeetingDetailView(meeting: meeting)
        }
    }

    private var templateFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedTemplate == nil
                ) {
                    viewModel.selectedTemplate = nil
                }

                ForEach(TemplateType.allCases) { template in
                    FilterChip(
                        title: template.displayName,
                        isSelected: viewModel.selectedTemplate == template
                    ) {
                        viewModel.selectedTemplate = template
                    }
                }
            }
            .padding(.horizontal)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private func deleteMeetings(at offsets: IndexSet) {
        let filtered = viewModel.filteredMeetings(meetings)
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.briefCaption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.briefAccent : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct MeetingRow: View {
    let meeting: Meeting

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: meeting.templateType.icon)
                .font(.title3)
                .foregroundStyle(meeting.templateType.isPrep ? Color.briefPrep : Color.briefDebrief)
                .frame(width: 36, height: 36)
                .background(
                    (meeting.templateType.isPrep ? Color.briefPrep : Color.briefDebrief).opacity(0.12)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.title)
                    .font(.briefHeadline)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(meeting.templateType.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            (meeting.templateType.isPrep ? Color.briefPrep : Color.briefDebrief).opacity(0.15)
                        )
                        .clipShape(Capsule())

                    if let insight = meeting.previewInsight {
                        Text(insight)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(meeting.date, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
