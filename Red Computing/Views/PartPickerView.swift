import SwiftUI

struct PartPickerView: View {
    let kind: PartKind
    let options: [Part]
    @Binding var selection: String

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
