import SwiftUI
import PDFKit

@MainActor
struct PDFExporter {

    static func exportMeeting(_ meeting: Meeting) -> Foundation.Data? {
        guard let resultJSON = meeting.resultJSON else { return nil }

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        let data = renderer.pdfData { context in
            var currentY: CGFloat = 0

            func ensureSpace(_ needed: CGFloat) {
                if currentY + needed > pageHeight - margin {
                    context.beginPage()
                    currentY = margin
                }
            }

            func beginFirstPage() {
                context.beginPage()
                currentY = margin
            }

            func drawTitle(_ text: String) {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                    .foregroundColor: UIColor(Color.briefAccent)
                ]
                let attrString = NSAttributedString(string: text, attributes: attrs)
                let size = attrString.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )
                ensureSpace(size.height + 20)
                attrString.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: size.height))
                currentY += size.height + 16
            }

            func drawSection(_ heading: String, items: [String]) {
                let headAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .foregroundColor: UIColor.darkGray
                ]
                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                    .foregroundColor: UIColor.black
                ]

                let headStr = NSAttributedString(string: heading, attributes: headAttrs)
                let headSize = headStr.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )
                ensureSpace(headSize.height + 10)
                headStr.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: headSize.height))
                currentY += headSize.height + 8

                for item in items {
                    let bullet = "\u{2022} \(item)"
                    let bodyStr = NSAttributedString(string: bullet, attributes: bodyAttrs)
                    let bodySize = bodyStr.boundingRect(
                        with: CGSize(width: contentWidth - 10, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin],
                        context: nil
                    )
                    ensureSpace(bodySize.height + 4)
                    bodyStr.draw(in: CGRect(x: margin + 10, y: currentY, width: contentWidth - 10, height: bodySize.height))
                    currentY += bodySize.height + 4
                }
                currentY += 12
            }

            func drawText(_ heading: String, text: String) {
                drawSection(heading, items: [text])
            }

            beginFirstPage()
            drawTitle(meeting.title)

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let dateStr = dateFormatter.string(from: meeting.date)
            let templateStr = meeting.templateType.displayName

            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.gray
            ]
            let subtitle = NSAttributedString(string: "\(templateStr) \u{2022} \(dateStr)", attributes: subtitleAttrs)
            subtitle.draw(at: CGPoint(x: margin, y: currentY))
            currentY += 24

            let decoder = JSONDecoder()

            switch meeting.templateType {
            case .prep:
                if let result = try? decoder.decode(MeetingPrep.self, from: resultJSON) {
                    drawSection("Talking Points", items: result.talkingPoints)
                    drawSection("Questions to Ask", items: result.questionsToAsk)
                    drawSection("Potential Pushback", items: result.potentialPushback)
                    drawSection("Suggested Structure", items: result.suggestedStructure)
                    drawSection("Time Allocation", items: result.timeAllocation)
                }
            case .debrief:
                if let result = try? decoder.decode(MeetingDebrief.self, from: resultJSON) {
                    drawSection("Decisions", items: result.decisions)
                    drawSection("Action Items", items: result.actionItems.map { "\($0.task) — \($0.owner) (Due: \($0.deadline))" })
                    drawSection("Open Questions", items: result.openQuestions)
                    drawText("Follow-Up Email", text: result.followUpEmail)
                }
            case .oneOnOne:
                if let result = try? decoder.decode(OneOnOnePrep.self, from: resultJSON) {
                    drawSection("Conversation Starters", items: result.starters)
                    drawSection("Topics to Cover", items: result.topicsToCover)
                    drawSection("Questions", items: result.questions)
                    drawSection("Follow-Ups", items: result.followUps)
                }
            case .presentation:
                if let result = try? decoder.decode(PresentationPrep.self, from: resultJSON) {
                    drawSection("Key Messages", items: result.keyMessages)
                    drawSection("Anticipated Questions", items: result.anticipatedQuestions)
                    drawText("Opening Hook", text: result.openingHook)
                    drawSection("Slide Structure", items: result.slideStructure)
                }
            }
        }

        return data
    }
}
