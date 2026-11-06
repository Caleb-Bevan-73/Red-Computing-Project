import SwiftUI

struct KnowledgeView: View {
    @State private var query = ""
    private var articles: [GuideArticle] {
        GuideArticle.library.filter {
            query.isEmpty || "\($0.title) \($0.summary) \($0.body)".localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageIntro(eyebrow: "THE KNOWLEDGE LIBRARY", title: "Know what goes\ninto your build.",
                          subtitle: "A little context makes every component choice clearer.", icon: "books.vertical")
                if articles.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
                ForEach(articles) { article in
                    ArticleLink(article: article)
                }
            }
            .padding(24)
            .frame(maxWidth: 850)
            .frame(maxWidth: .infinity)
        }
        .searchable(text: $query, prompt: "Search building, graphics, memory…")
        .navigationTitle("Learn")
    }
}
