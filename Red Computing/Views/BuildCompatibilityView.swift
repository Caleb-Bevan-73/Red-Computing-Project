import SwiftUI

struct BuildCompatibilityView: View {
    let checks: [CompatibilityCheck]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Compatibility checks", systemImage: "checklist").font(.title3.bold())
            Text("Checks cover documented parts and installation assumptions. Unknown does not mean compatible.")
                .font(.subheadline).foregroundStyle(.secondary)
            ForEach(checks) { check in
                CompatibilityCheckView(check: check)
            }
        }
        .workshopCard()
    }
}
