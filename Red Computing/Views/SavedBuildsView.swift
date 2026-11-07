import SwiftUI

struct SavedBuildsView: View {
    @Bindable var viewModel: MyBuildsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Saved Builds", systemImage: "folder").font(.title2.bold())
            Text(viewModel.activeBuildName).font(.headline)
            Text(viewModel.hasUnsavedChanges ? "Unsaved changes" : (viewModel.activeBuildID == nil ? "Choose components, then save your build." : "All changes saved"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let message = viewModel.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .accessibilityIdentifier("buildStorageError")
            }
            if !viewModel.storageAvailable {
                Button("Retry Loading Saved Builds", action: viewModel.retryLoad)
                    .buttonStyle(.bordered)
            }

            VStack(alignment: .leading, spacing: 10) {
                Button("Save", systemImage: "square.and.arrow.down", action: viewModel.save)
                    .buttonStyle(.borderedProminent)
                Button("Save as New", systemImage: "doc.on.doc", action: viewModel.saveAsNew)
                    .buttonStyle(.bordered)
                Button("New Build", systemImage: "plus", action: viewModel.newBuild)
                    .buttonStyle(.bordered)
            }
            .disabled(!viewModel.storageAvailable)

            Divider()
            if viewModel.savedBuilds.isEmpty {
                Text(viewModel.storageAvailable
                     ? "No saved builds yet. Save a name for your current configuration—even if you haven’t chosen every part."
                     : "Saved builds are unavailable until loading succeeds.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.savedBuilds) { build in
                    Button {
                        viewModel.openBuild(build.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(build.name).font(.headline)
                                Text(build.id == viewModel.activeBuildID ? "Active build · Tap to reopen saved version" : "Open saved build")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: build.id == viewModel.activeBuildID ? "checkmark.circle" : "chevron.right")
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(build.name)")
                    .accessibilityAddTraits(build.id == viewModel.activeBuildID ? .isSelected : [])
                }
            }
        }
        .workshopCard()
    }
}
