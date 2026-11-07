import Foundation

struct BuildConfiguration: Codable, Equatable {
    var cpuID = ""
    var gpuID = ""
    var motherboardID = ""
    var ramID = ""
    var storageID = ""
    var psuID = ""

    subscript(kind: PartKind) -> String {
        get {
            switch kind {
            case .cpu: cpuID
            case .gpu: gpuID
            case .motherboard: motherboardID
            case .ram: ramID
            case .storage: storageID
            case .psu: psuID
            }
        }
        set {
            switch kind {
            case .cpu: cpuID = newValue
            case .gpu: gpuID = newValue
            case .motherboard: motherboardID = newValue
            case .ram: ramID = newValue
            case .storage: storageID = newValue
            case .psu: psuID = newValue
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case cpuID, gpuID, motherboardID, ramID, storageID, psuID
    }

    init(cpuID: String = "", gpuID: String = "", motherboardID: String = "",
         ramID: String = "", storageID: String = "", psuID: String = "") {
        self.cpuID = cpuID
        self.gpuID = gpuID
        self.motherboardID = motherboardID
        self.ramID = ramID
        self.storageID = storageID
        self.psuID = psuID
    }

    // Version-one snapshots contain only CPU/GPU IDs. Missing selections stay unset.
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cpuID = try values.decodeIfPresent(String.self, forKey: .cpuID) ?? ""
        gpuID = try values.decodeIfPresent(String.self, forKey: .gpuID) ?? ""
        motherboardID = try values.decodeIfPresent(String.self, forKey: .motherboardID) ?? ""
        ramID = try values.decodeIfPresent(String.self, forKey: .ramID) ?? ""
        storageID = try values.decodeIfPresent(String.self, forKey: .storageID) ?? ""
        psuID = try values.decodeIfPresent(String.self, forKey: .psuID) ?? ""
    }
}
