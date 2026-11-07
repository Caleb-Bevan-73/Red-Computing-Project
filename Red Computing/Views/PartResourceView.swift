import SwiftUI

struct PartResourceView: View {
    private let viewModel: PartResourceViewModel

    init(part: Part) {
        viewModel = PartResourceViewModel(part: part)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.part.detail).font(.caption).foregroundStyle(.secondary)
            Text(viewModel.part.name).font(.headline)
            Text(viewModel.part.technology).font(.subheadline).foregroundStyle(.secondary)
            if let url = viewModel.manufacturerURL {
                Link(destination: url) {
                    Label("Manufacturer resource", systemImage: "arrow.up.right")
                }
            }
            if let url = viewModel.cpuSupportURL {
                Link("Exact CPU support and BIOS list", destination: url)
                    .font(.subheadline)
            }
            NavigationLink {
                ArticleDetailView(article: viewModel.guideArticle)
            } label: {
                Label(viewModel.guideTitle, systemImage: "book")
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .workshopCard()
    }
}
