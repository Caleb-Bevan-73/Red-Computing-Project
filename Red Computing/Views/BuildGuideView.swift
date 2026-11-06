import SwiftUI

struct BuildGuideView: View {
    @AppStorage("selectedCPU") private var cpuID = ""
    @AppStorage("selectedGPU") private var gpuID = ""

    private var selectedParts: [Part] {
        [Part.selected(cpuID), Part.selected(gpuID)].compactMap { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                PageIntro(eyebrow: "RED COMPUTING / WORKSHOP", title: "Your next build\nstarts here.",
                          subtitle: "Choose your parts. Understand your options. Build with confidence.", icon: "square.stack.3d.up")
                VStack(alignment: .leading, spacing: 18) {
                    Label("Your core components", systemImage: "cpu").font(.title3.bold())
                    Text("A starter catalog to shape your personal reading list.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    PartPicker(kind: .cpu, selection: $cpuID)
                    Divider()
                    PartPicker(kind: .gpu, selection: $gpuID)
                    Text("\(selectedParts.count) of 2 core parts selected · Saved on this device")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .workshopCard()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Made for your build").font(.title2.bold())
                    if selectedParts.isEmpty {
                        Label("Select a CPU or GPU to unlock matching manufacturer resources.", systemImage: "link")
                            .foregroundStyle(.secondary)
                            .workshopCard()
                    }
                    ForEach(selectedParts) { part in
                        PartResourceView(part: part)
                    }
                    ArticleLink(article: .compatibility)
                    ArticleLink(article: .checklist)
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
        .navigationTitle("My build")
    }
}
