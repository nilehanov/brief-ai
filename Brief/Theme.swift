import SwiftUI

extension Color {
    static let briefAccent = Color(red: 0.15, green: 0.25, blue: 0.45)
    static let briefSuccess = Color(red: 0.15, green: 0.68, blue: 0.38)
    static let briefPrep = Color(red: 0.20, green: 0.50, blue: 0.85)
    static let briefDebrief = Color(red: 0.85, green: 0.50, blue: 0.20)
}

extension Font {
    static let briefTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let briefHeadline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let briefBody = Font.system(.body, design: .default)
    static let briefCaption = Font.system(.caption, design: .rounded, weight: .medium)
}

struct BriefCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func briefCard() -> some View {
        modifier(BriefCardStyle())
    }
}
