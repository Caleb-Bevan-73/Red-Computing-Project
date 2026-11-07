import Foundation

enum CompatibilityStatus: String {
    case incompatible = "Incompatible"
    case conditional = "Conditional"
    case unknown = "Unknown"
    case compatible = "Compatible"
}

struct CompatibilityCheck: Identifiable {
    let id: String
    let kinds: Set<PartKind>
    let status: CompatibilityStatus
    let message: String
}
