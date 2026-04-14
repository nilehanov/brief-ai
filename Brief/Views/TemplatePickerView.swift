import SwiftUI

struct TemplatePickerView: View {
    @Binding var selected: TemplateType

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(TemplateType.allCases) { template in
                TemplateCard(
                    template: template,
                    isSelected: selected == template
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = template
                    }
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: TemplateType
    let isSelected: Bool
    let action: () -> Void

    private var accentColor: Color {
        template.isPrep ? .briefPrep : .briefDebrief
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : accentColor)

                Text(template.displayName)
                    .font(.briefCaption)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(isSelected ? accentColor : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        switch template {
        case .prep: "Talking points & structure"
        case .debrief: "Decisions & action items"
        case .oneOnOne: "Topics & conversation starters"
        case .presentation: "Key messages & slides"
        }
    }
}
