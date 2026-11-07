import SwiftUI

struct CompatibilityCheckView: View {
    let check: CompatibilityCheck

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(check.status.rawValue, systemImage: check.status == .incompatible ? "xmark.octagon" :
                    check.status == .compatible ? "checkmark.circle" :
                    check.status == .conditional ? "exclamationmark.triangle" : "questionmark.circle")
                .font(.subheadline.bold())
                .foregroundStyle(check.status == .incompatible ? Color.red : Color.primary)
            Text(check.message).font(.subheadline).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
