import Foundation

enum PartKind: String, CaseIterable, Identifiable, Codable {
    case cpu = "CPU"
    case gpu = "GPU"
    case motherboard = "Motherboard"
    case ram = "RAM"
    case storage = "Storage"
    case psu = "PSU"

    var id: String { rawValue }
    var title: String {
        switch self {
        case .cpu: "Processor"
        case .gpu: "Graphics card"
        case .motherboard: "Motherboard"
        case .ram: "Memory kit"
        case .storage: "Storage drive"
        case .psu: "Power supply"
        }
    }
}
