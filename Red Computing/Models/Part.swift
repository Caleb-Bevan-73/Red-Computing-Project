import Foundation

struct Part: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: PartKind
    let detail: String
    let technology: String
    let resource: String

    var specifications: ComponentSpecifications = .unknown
}
