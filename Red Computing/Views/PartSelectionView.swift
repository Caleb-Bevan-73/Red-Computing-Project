import SwiftUI

struct PartSelectionView: View {
    let kind: PartKind
    let viewModel: MyBuildsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("One \(kind.title.lowercased()) per build. Incompatible choices are unavailable; conditional and unknown checks need your attention.")
                    .font(.subheadline).foregroundStyle(.secondary)
                ForEach(viewModel.options(for: kind)) { option in
                    VStack(alignment: .leading, spacing: 16) {
                        PartResourceView(part: option.part)
                        ForEach(option.checks) { check in
                            CompatibilityCheckView(check: check)
                        }
                        if viewModel.configuration[kind] == option.id {
                            Label("Selected", systemImage: "checkmark.circle").font(.headline)
                            Button("Remove \(kind.title)") { viewModel.select("", for: kind) }
                                .buttonStyle(.bordered)
                        } else {
                            Button("Select \(option.part.name)") { viewModel.select(option.id, for: kind) }
                                .buttonStyle(.borderedProminent)
                                .disabled(!option.canSelect)
                        }
                    }
                    Divider()
                }
            }
            .padding(24)
            .frame(maxWidth: 850)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(kind.title)
    }
}
