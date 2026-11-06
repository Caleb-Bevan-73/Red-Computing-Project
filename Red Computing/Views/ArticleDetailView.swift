import SwiftUI

struct ArticleDetailView: View {
    let article: GuideArticle
    private var related: [GuideArticle] {
        GuideArticle.library.filter { $0.id != article.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageIntro(eyebrow: article.category, title: article.title, subtitle: article.summary, icon: article.icon)
                Text(article.body).lineSpacing(6).textSelection(.enabled)
                if let url = URL(string: article.source) {
                    Link(destination: url) {
                        Label(article.sourceTitle, systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.bordered)
                }
                Divider()
                Text("Keep learning").font(.title2.bold())
                ForEach(related) { item in
                    ArticleLink(article: item)
                }
            }
            .padding(24)
            .frame(maxWidth: 750)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Field guide")
    }
}
