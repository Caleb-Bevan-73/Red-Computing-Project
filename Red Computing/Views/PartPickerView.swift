import SwiftUI

struct PartPickerView: View {
    let kind: PartKind
    let viewModel: MyBuildsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kind.title).font(.headline)
            Menu {
                Button("None / Remove selection") {
                    viewModel.select("", for: kind)
                }
                ForEach(viewModel.options(for: kind)) { option in
                    Button {
                        viewModel.select(option.id, for: kind)
                    } label: {
                        Text("\(option.part.name) — \(option.status.rawValue)")
                    }
                    .disabled(!option.canSelect)
                }
            } label: {
                Label(viewModel.selectedPart(for: kind)?.name ?? "Choose \(kind.title)",
                      systemImage: "chevron.up.chevron.down")
                    .multilineTextAlignment(.leading)
            }
            .accessibilityLabel(kind.title)
            .accessibilityValue(viewModel.selectedPart(for: kind)?.name ?? "None")
            NavigationLink {
                PartSelectionView(kind: kind, viewModel: viewModel)
            } label: {
                Text("Browse \(kind.rawValue) options and compatibility")
                    .font(.subheadline)
            }
        }
    }
}
