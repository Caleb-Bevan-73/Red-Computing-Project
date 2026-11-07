import Foundation

struct ArticleDetailViewModel {
    let article: GuideArticle
    let relatedArticles: [GuideArticle]
    let sourceURL: URL?

    init(article: GuideArticle) {
        self.init(article: article, library: GuideArticle.library)
    }

    init(article: GuideArticle, library: [GuideArticle]) {
        self.article = article
        relatedArticles = library.filter { $0.id != article.id }
        sourceURL = URL(string: article.source)
    }
}
