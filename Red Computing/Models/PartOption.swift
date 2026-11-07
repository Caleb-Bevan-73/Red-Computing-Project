import Foundation

struct PartOption: Identifiable {
    let part: Part
    let checks: [CompatibilityCheck]
    var id: String { part.id }
    var canSelect: Bool { !checks.contains { $0.status == .incompatible } }
    var status: CompatibilityStatus {
        if !canSelect { return .incompatible }
        if checks.contains(where: { $0.status == .unknown }) { return .unknown }
        if checks.contains(where: { $0.status == .conditional }) { return .conditional }
        return .compatible
    }
}
