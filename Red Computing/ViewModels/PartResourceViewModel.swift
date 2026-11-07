import Foundation

/// Immutable presentation data for a component's manufacturer links and field guide.
struct PartResourceViewModel {
    let part: Part
    let manufacturerURL: URL?
    let cpuSupportURL: URL?
    let guideArticle: GuideArticle
    let guideTitle: String

    init(part: Part) {
        self.part = part
        manufacturerURL = URL(string: part.resource)
        if case .motherboard(let specifications) = part.specifications {
            cpuSupportURL = URL(string: specifications.cpuSupportURL)
        } else {
            cpuSupportURL = nil
        }
        guideArticle = part.kind == .gpu ? .features : .compatibility
        guideTitle = part.kind == .gpu ? "Understand graphics technologies" : "Understand platform compatibility"
    }
}
