import SwiftUI

struct PartPicker: View {
    let kind: PartKind
    @Binding var selection: String
    private var options: [Part] { Part.catalog.filter { $0.kind == kind } }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kind == .cpu ? "Processor" : "Graphics card").font(.headline)
            Picker(kind.rawValue, selection: $selection) {
                Text("Choose a \(kind.rawValue)").tag("")
                ForEach(options) { part in
                    Text(part.name).tag(part.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .accessibilityLabel(kind == .cpu ? "Processor" : "Graphics card")
        }
    }
}
