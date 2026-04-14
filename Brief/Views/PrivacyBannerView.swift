import SwiftUI

struct PrivacyBannerView: View {
    var icon: String = "lock.shield"
    var text: String = "All AI processing happens on-device using Apple Intelligence. Your meeting data never leaves your device."
    var color: Color = .briefSuccess

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
