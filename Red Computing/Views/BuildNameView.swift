import SwiftUI

struct BuildNameView: View {
    @Bindable var viewModel: MyBuildsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Build name") {
                    TextField("For example, Gaming PC", text: $viewModel.buildName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit { viewModel.submitName() }
                    Text("You can save a build before selecting all its components.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let message = viewModel.errorMessage {
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle")
                    }
                }
            }
            .navigationTitle("Save Build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: viewModel.cancelNaming)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: viewModel.submitName)
                        .disabled(!viewModel.canSubmitName)
                }
            }
        }
    }
}
