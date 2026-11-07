import Foundation
import Observation

@MainActor
@Observable
final class KnowledgeViewModel {
    var query = ""
    private let library: [GuideArticle]

    convenience init() {
        self.init(library: GuideArticle.library)
    }

    init(library: [GuideArticle]) {
        self.library = library
    }

    var articles: [GuideArticle] {
        library.filter {
            query.isEmpty || "\($0.title) \($0.summary) \($0.body)".localizedCaseInsensitiveContains(query)
        }
    }
}
