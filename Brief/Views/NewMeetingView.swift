import SwiftUI
import SwiftData

struct NewMeetingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var inputText = ""
    @State private var selectedTemplate: TemplateType = .prep
    @State private var isGenerating = false
    @State private var error: String?
    @State private var aiUnavailable = false

    private let service = BriefService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if aiUnavailable {
                        PrivacyBannerView(
                            icon: "exclamationmark.triangle",
                            text: "Apple Intelligence is not available on this device. You need an iPhone or iPad with Apple Intelligence to use Brief.",
                            color: .orange
                        )
                    }

                    titleSection
                    templateSection
                    inputSection

                    if let error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                    }

                    generateButton
                }
                .padding()
            }
            .navigationTitle("New Brief")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                aiUnavailable = !BriefService.isAvailable
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meeting Title")
                .font(.briefHeadline)
            TextField("e.g. Q4 Planning Review", text: $title)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Template")
                .font(.briefHeadline)
            TemplatePickerView(selected: $selectedTemplate)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedTemplate.isPrep ? "Meeting Context / Agenda" : "Meeting Notes")
                .font(.briefHeadline)

            TextEditor(text: $inputText)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text(placeholderText)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                Button {
                    if let clipboard = UIPasteboard.general.string {
                        inputText = clipboard
                    }
                } label: {
                    Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(Color.briefAccent)

                Spacer()

                Text("\(inputText.count) characters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var generateButton: some View {
        Button {
            Task { await generateBrief() }
        } label: {
            HStack(spacing: 8) {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                }
                Text(isGenerating ? "Generating..." : "Generate Brief")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.briefAccent)
        .disabled(title.isEmpty || inputText.isEmpty || isGenerating || aiUnavailable)
    }

    private var placeholderText: String {
        switch selectedTemplate {
        case .prep:
            "Paste the meeting agenda, context, or goals..."
        case .debrief:
            "Paste your raw meeting notes, decisions, and discussion points..."
        case .oneOnOne:
            "Paste context about the person, previous topics, or goals for this 1:1..."
        case .presentation:
            "Paste the presentation topic, audience info, and key objectives..."
        }
    }

    private func generateBrief() async {
        isGenerating = true
        error = nil

        do {
            let resultData = try await service.generate(for: selectedTemplate, input: inputText)
            let meeting = Meeting(
                title: title,
                inputText: inputText,
                templateType: selectedTemplate,
                resultJSON: resultData,
                previewInsight: service.previewInsight(for: selectedTemplate, data: resultData)
            )
            modelContext.insert(meeting)
            try modelContext.save()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }

        isGenerating = false
    }
}
