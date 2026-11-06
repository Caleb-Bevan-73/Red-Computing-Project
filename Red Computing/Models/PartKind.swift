import Foundation

enum PartKind: String, CaseIterable, Identifiable {
    case cpu = "CPU"
    case gpu = "GPU"
    var id: String { rawValue }
}
