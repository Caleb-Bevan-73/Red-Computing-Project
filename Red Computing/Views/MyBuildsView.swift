import SwiftUI

struct MyBuildsView: View {
    @State private var viewModel = MyBuildsViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                PageIntroView(eyebrow: "RED COMPUTING / WORKSHOP", title: "Your next build\nstarts here.",
                          subtitle: "Choose your parts. Understand your options. Build with confidence.", icon: "square.stack.3d.up")
                SavedBuildsView(viewModel: viewModel)

                VStack(alignment: .leading, spacing: 18) {
                    Label("Your core components", systemImage: "cpu").font(.title3.bold())
                    Text("A starter catalog to shape your personal reading list.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    PartPickerView(kind: .cpu, options: viewModel.cpuOptions, selection: $viewModel.cpuID)
                    Divider()
                    PartPickerView(kind: .gpu, options: viewModel.gpuOptions, selection: $viewModel.gpuID)
                    Text("\(viewModel.selectedParts.count) of 2 core parts selected")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .workshopCard()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Made for your build").font(.title2.bold())
                    if viewModel.selectedParts.isEmpty {
                        Label("Select a CPU or GPU to unlock matching manufacturer resources.", systemImage: "link")
                            .foregroundStyle(.secondary)
                            .workshopCard()
                    }
                    ForEach(viewModel.selectedParts) { part in
                        PartResourceView(part: part)
                    }
                    ArticleLinkView(article: .compatibility)
                    ArticleLinkView(article: .checklist)
                }
                NavigationLink {
                    ComparisonView()
                } label: {
                    Label("Explore performance comparisons", systemImage: "arrow.up.right")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
            .frame(maxWidth: 850)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("My Builds")
        .confirmationDialog("Save your changes before continuing?",
                            isPresented: $viewModel.showingUnsavedChanges,
                            titleVisibility: .visible) {
            Button("Save and Continue", action: viewModel.saveAndContinue)
            Button("Discard Changes", role: .destructive, action: viewModel.discardAndContinue)
            Button("Cancel", role: .cancel, action: viewModel.cancelSwitch)
        } message: {
            Text("Your saved builds will stay unchanged unless you save.")
        }
        .sheet(isPresented: $viewModel.showingNamePrompt, onDismiss: viewModel.cancelNaming) {
            BuildNameView(viewModel: viewModel)
        }
    }
}
