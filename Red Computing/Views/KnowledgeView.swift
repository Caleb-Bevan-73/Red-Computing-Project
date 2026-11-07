import SwiftUI

struct KnowledgeView: View {
    @State private var viewModel = KnowledgeViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageIntroView(eyebrow: "THE KNOWLEDGE LIBRARY", title: "Know what goes\ninto your build.",
                          subtitle: "A little context makes every component choice clearer.", icon: "books.vertical")
                if viewModel.articles.isEmpty {
                    ContentUnavailableView.search(text: viewModel.query)
                }
                ForEach(viewModel.articles) { article in
                    ArticleLinkView(article: article)
                }
            }
            .padding(24)
            .frame(maxWidth: 850)
            .frame(maxWidth: .infinity)
        }
        .searchable(text: $viewModel.query, prompt: "Search building, graphics, memory…")
        .navigationTitle("Learn")
    }
}
