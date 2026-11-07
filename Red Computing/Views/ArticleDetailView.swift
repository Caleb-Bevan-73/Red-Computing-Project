import SwiftUI

struct ArticleDetailView: View {
    private let viewModel: ArticleDetailViewModel

    init(article: GuideArticle) {
        viewModel = ArticleDetailViewModel(article: article)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageIntroView(eyebrow: viewModel.article.category, title: viewModel.article.title, subtitle: viewModel.article.summary, icon: viewModel.article.icon)
                Text(viewModel.article.body).lineSpacing(6).textSelection(.enabled)
                if let url = viewModel.sourceURL {
                    Link(destination: url) {
                        Label(viewModel.article.sourceTitle, systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.bordered)
                }
                Divider()
                Text("Keep learning").font(.title2.bold())
                ForEach(viewModel.relatedArticles) { item in
                    ArticleLinkView(article: item)
                }
            }
            .padding(24)
            .frame(maxWidth: 750)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Field guide")
    }
}
