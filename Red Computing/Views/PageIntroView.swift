import SwiftUI

struct PageIntroView: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(eyebrow, systemImage: icon)
                .font(.caption.weight(.bold))
                .tracking(2)
                .foregroundStyle(WorkshopTheme.accent)
            Text(title)
                .font(.largeTitle.bold())
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}
