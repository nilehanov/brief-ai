import SwiftUI

struct MeetingDetailView: View {
    let meeting: Meeting
    @State private var viewModel = MeetingDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection

                if viewModel.isGenerating {
                    generatingView
                } else if let resultJSON = meeting.resultJSON {
                    resultContent(resultJSON)
                } else {
                    noResultView
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(meeting.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if meeting.resultJSON != nil {
                    Button {
                        viewModel.exportPDF(for: meeting)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                Menu {
                    Button {
                        Task { await viewModel.generate(for: meeting) }
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingShareSheet) {
            if let pdfData = viewModel.pdfData {
                ShareSheet(items: [pdfData])
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: meeting.templateType.icon)
                    .foregroundStyle(meeting.templateType.isPrep ? Color.briefPrep : Color.briefDebrief)
                Text(meeting.templateType.displayName)
                    .font(.briefCaption)
                    .foregroundStyle(meeting.templateType.isPrep ? Color.briefPrep : Color.briefDebrief)
                Spacer()
                Text(meeting.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !meeting.inputText.isEmpty {
                DisclosureGroup("Original Input") {
                    Text(meeting.inputText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.briefCaption)
            }
        }
        .briefCard()
    }

    private var generatingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating your brief...")
                .font(.briefHeadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .briefCard()
    }

    private var noResultView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(Color.briefAccent)
            Text("No results yet")
                .font(.briefHeadline)
            Button("Generate Brief") {
                Task { await viewModel.generate(for: meeting) }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.briefAccent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .briefCard()
    }

    @ViewBuilder
    private func resultContent(_ data: Foundation.Data) -> some View {
        let decoder = JSONDecoder()

        switch meeting.templateType {
        case .prep:
            if let result = try? decoder.decode(MeetingPrep.self, from: data) {
                prepContent(result)
            }
        case .debrief:
            if let result = try? decoder.decode(MeetingDebrief.self, from: data) {
                debriefContent(result)
            }
        case .oneOnOne:
            if let result = try? decoder.decode(OneOnOnePrep.self, from: data) {
                oneOnOneContent(result)
            }
        case .presentation:
            if let result = try? decoder.decode(PresentationPrep.self, from: data) {
                presentationContent(result)
            }
        }
    }

    private func prepContent(_ result: MeetingPrep) -> some View {
        VStack(spacing: 12) {
            SectionCard(title: "Talking Points", icon: "text.bubble", items: result.talkingPoints, color: .briefPrep)
            SectionCard(title: "Questions to Ask", icon: "questionmark.circle", items: result.questionsToAsk, color: .briefAccent)
            SectionCard(title: "Potential Pushback", icon: "shield", items: result.potentialPushback, color: .orange)
            SectionCard(title: "Suggested Structure", icon: "list.number", items: result.suggestedStructure, color: .briefSuccess)
            SectionCard(title: "Time Allocation", icon: "clock", items: result.timeAllocation, color: .purple)
        }
    }

    private func debriefContent(_ result: MeetingDebrief) -> some View {
        VStack(spacing: 12) {
            SectionCard(title: "Decisions", icon: "checkmark.seal", items: result.decisions, color: .briefSuccess)
            actionItemsCard(result.actionItems)
            SectionCard(title: "Open Questions", icon: "questionmark.diamond", items: result.openQuestions, color: .orange)
            followUpEmailCard(result.followUpEmail)
        }
    }

    private func oneOnOneContent(_ result: OneOnOnePrep) -> some View {
        VStack(spacing: 12) {
            SectionCard(title: "Conversation Starters", icon: "bubble.left.and.bubble.right", items: result.starters, color: .briefPrep)
            SectionCard(title: "Topics to Cover", icon: "list.bullet", items: result.topicsToCover, color: .briefAccent)
            SectionCard(title: "Questions", icon: "questionmark.circle", items: result.questions, color: .briefSuccess)
            SectionCard(title: "Follow-Ups", icon: "arrow.uturn.backward", items: result.followUps, color: .purple)
        }
    }

    private func presentationContent(_ result: PresentationPrep) -> some View {
        VStack(spacing: 12) {
            SectionCard(title: "Key Messages", icon: "megaphone", items: result.keyMessages, color: .briefPrep)
            SectionCard(title: "Anticipated Questions", icon: "questionmark.bubble", items: result.anticipatedQuestions, color: .orange)

            VStack(alignment: .leading, spacing: 8) {
                Label("Opening Hook", systemImage: "sparkles")
                    .font(.briefHeadline)
                    .foregroundStyle(Color.briefSuccess)
                Text(result.openingHook)
                    .font(.briefBody)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .briefCard()

            SectionCard(title: "Slide Structure", icon: "rectangle.split.3x1", items: result.slideStructure, color: .briefAccent)
        }
    }

    private func actionItemsCard(_ items: [ActionItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Action Items", systemImage: "checklist")
                .font(.briefHeadline)
                .foregroundStyle(Color.briefAccent)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundStyle(Color.briefAccent)
                        .padding(.top, 3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.task)
                            .font(.briefBody)

                        HStack(spacing: 8) {
                            Label(item.owner, systemImage: "person")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.briefAccent.opacity(0.1))
                                .clipShape(Capsule())

                            if !item.deadline.isEmpty {
                                Label(item.deadline, systemImage: "calendar")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .briefCard()
    }

    private func followUpEmailCard(_ email: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Follow-Up Email", systemImage: "envelope")
                    .font(.briefHeadline)
                    .foregroundStyle(Color.briefPrep)
                Spacer()
                Button {
                    UIPasteboard.general.string = email
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            Text(email)
                .font(.briefBody)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .briefCard()
    }
}

struct SectionCard: View {
    let title: String
    let icon: String
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.briefHeadline)
                .foregroundStyle(color)

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(color.opacity(0.7))
                        .frame(width: 20, alignment: .trailing)
                    Text(item)
                        .font(.briefBody)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .briefCard()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
