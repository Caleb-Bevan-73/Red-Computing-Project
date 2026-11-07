import SwiftUI

struct ArticleLinkView: View {
    let article: GuideArticle

    var body: some View {
        NavigationLink {
            ArticleDetailView(article: article)
        } label: {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: article.icon)
                    .font(.title2).foregroundStyle(WorkshopTheme.accent)
                    .frame(width: 32)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.category).font(.caption2.bold()).tracking(1).foregroundStyle(.secondary)
                    Text(article.title).font(.headline).foregroundStyle(.primary)
                    Text(article.summary).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .workshopCard()
        }
        .buttonStyle(.plain)
    }
}
