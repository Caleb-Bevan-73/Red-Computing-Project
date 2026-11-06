import SwiftUI

struct PartResourceView: View {
    let part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(part.detail).font(.caption).foregroundStyle(.secondary)
            Text(part.name).font(.headline)
            Text(part.technology).font(.subheadline).foregroundStyle(.secondary)
            if let url = URL(string: part.resource) {
                Link(destination: url) {
                    Label("Manufacturer resource", systemImage: "arrow.up.right")
                }
            }
            NavigationLink {
                ArticleDetailView(article: part.kind == .cpu ? .compatibility : .features)
            } label: {
                Label(part.kind == .cpu ? "Understand platform compatibility" : "Understand graphics technologies",
                      systemImage: "book")
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .workshopCard()
    }
}
