import Foundation

enum GPUResolution: String, CaseIterable, Identifiable {
    case fullHD = "1080p"
    case quadHD = "1440p"
    case ultraHD = "4K"

    var id: String { rawValue }
}

struct GPUBenchmark: Identifiable {
    let id: String
    let fullHD: Double
    let quadHD: Double
    let ultraHD: Double

    static let architectures = ["Blackwell / Ada", "RDNA 4 / 3", "Ampere", "RDNA 2", "Battlemage"]

    var architecture: String {
        if id.hasPrefix("RTX 3") { return "Ampere" }
        if id.hasPrefix("RTX") { return "Blackwell / Ada" }
        if id.hasPrefix("RX 6") { return "RDNA 2" }
        if id.hasPrefix("RX") { return "RDNA 4 / 3" }
        return "Battlemage"
    }

    func fps(at resolution: GPUResolution) -> Double {
        switch resolution {
        case .fullHD: fullHD
        case .quadHD: quadHD
        case .ultraHD: ultraHD
        }
    }

    // Tom's Hardware, June 24, 2026 rasterization TABLE, retrieved November 6, 2026.
    // The source's chart images differ from its table for some entries;
    // preserve the published table values consistently across all resolutions.
    // https://www.tomshardware.com/reviews/gpu-hierarchy,4388.html
    static let snapshot: [GPUBenchmark] = [
        GPUBenchmark(id: "RTX 5090", fullHD: 203.8, quadHD: 167.3, ultraHD: 110.8),
        GPUBenchmark(id: "RTX 4090", fullHD: 183.6, quadHD: 143.4, ultraHD: 89.1),
        GPUBenchmark(id: "RTX 5080", fullHD: 166.9, quadHD: 128.3, ultraHD: 77.4),
        GPUBenchmark(id: "RX 7900 XTX", fullHD: 161.5, quadHD: 122.3, ultraHD: 70.6),
        GPUBenchmark(id: "RTX 4080 Super", fullHD: 158.9, quadHD: 118.6, ultraHD: 69.4),
        GPUBenchmark(id: "RTX 4080", fullHD: 157.3, quadHD: 117.5, ultraHD: 67.5),
        GPUBenchmark(id: "RTX 5070 Ti", fullHD: 155.4, quadHD: 116.8, ultraHD: 68.6),
        GPUBenchmark(id: "RX 9070 XT", fullHD: 156.6, quadHD: 116.5, ultraHD: 65.8),
        GPUBenchmark(id: "RX 7900 XT", fullHD: 145.4, quadHD: 108.0, ultraHD: 59.8),
        GPUBenchmark(id: "RTX 4070 Ti Super", fullHD: 141.2, quadHD: 104.0, ultraHD: 58.5),
        GPUBenchmark(id: "RX 9070", fullHD: 140.9, quadHD: 104.0, ultraHD: 57.7),
        GPUBenchmark(id: "RTX 3090 Ti", fullHD: 131.7, quadHD: 99.9, ultraHD: 59.3),
        GPUBenchmark(id: "RTX 4070 Ti", fullHD: 135.1, quadHD: 97.9, ultraHD: 53.9),
        GPUBenchmark(id: "RTX 5070", fullHD: 132.6, quadHD: 96.4, ultraHD: 54.3),
        GPUBenchmark(id: "RTX 3090", fullHD: 122.9, quadHD: 91.5, ultraHD: 53.1),
        GPUBenchmark(id: "RTX 4070 Super", fullHD: 126.7, quadHD: 91.2, ultraHD: 49.2),
        GPUBenchmark(id: "RX 6950 XT", fullHD: 123.3, quadHD: 89.5, ultraHD: 48.3),
        GPUBenchmark(id: "RTX 3080 Ti", fullHD: 119.6, quadHD: 89.1, ultraHD: 51.0),
        GPUBenchmark(id: "RX 9070 GRE", fullHD: 120.6, quadHD: 86.6, ultraHD: 46.3),
        GPUBenchmark(id: "RX 7800 XT", fullHD: 118.4, quadHD: 84.7, ultraHD: 45.1),
        GPUBenchmark(id: "RX 6900 XT", fullHD: 117.1, quadHD: 83.9, ultraHD: 44.9),
        GPUBenchmark(id: "RTX 3080", fullHD: 111.6, quadHD: 82.0, ultraHD: 43.9),
        GPUBenchmark(id: "RX 6800 XT", fullHD: 111.8, quadHD: 79.6, ultraHD: 42.2),
        GPUBenchmark(id: "RTX 4070", fullHD: 111.5, quadHD: 77.8, ultraHD: 41.3),
        GPUBenchmark(id: "RTX 5060 Ti 16GB", fullHD: 105.2, quadHD: 73.4, ultraHD: 40.2),
        GPUBenchmark(id: "RX 7700 XT", fullHD: 102.9, quadHD: 72.7, ultraHD: 38.0),
        GPUBenchmark(id: "RX 9060 XT 16GB", fullHD: 98.3, quadHD: 67.3, ultraHD: 35.2),
        GPUBenchmark(id: "RTX 5060 Ti 8GB", fullHD: 100.4, quadHD: 68.6, ultraHD: 28.1),
        GPUBenchmark(id: "RTX 3070 Ti", fullHD: 94.6, quadHD: 66.9, ultraHD: 26.0),
        GPUBenchmark(id: "RX 9060 XT 8GB", fullHD: 93.2, quadHD: 62.5, ultraHD: 29.7),
        GPUBenchmark(id: "RTX 4060 Ti 16GB", fullHD: 89.3, quadHD: 60.5, ultraHD: 31.3),
        GPUBenchmark(id: "RX 7600 XT", fullHD: 102.1, quadHD: 50.2, ultraHD: 25.5),
        GPUBenchmark(id: "RTX 3070", fullHD: 87.2, quadHD: 58.2, ultraHD: 26.2),
        GPUBenchmark(id: "RTX 4060 Ti 8GB", fullHD: 88.0, quadHD: 58.9, ultraHD: 23.9),
        GPUBenchmark(id: "RX 6750 XT", fullHD: 83.2, quadHD: 57.6, ultraHD: 29.6),
        GPUBenchmark(id: "RTX 5060", fullHD: 88.5, quadHD: 59.8, ultraHD: 21.8),
        GPUBenchmark(id: "RX 6700 XT", fullHD: 79.2, quadHD: 54.3, ultraHD: 28.0),
        GPUBenchmark(id: "Arc B580", fullHD: 71.5, quadHD: 50.7, ultraHD: 27.6),
        GPUBenchmark(id: "RTX 3060 Ti", fullHD: 74.2, quadHD: 51.0, ultraHD: 19.4),
        GPUBenchmark(id: "RTX 4060", fullHD: 71.5, quadHD: 47.6, ultraHD: 17.4),
        GPUBenchmark(id: "RX 7600", fullHD: 69.9, quadHD: 45.4, ultraHD: 18.4),
        GPUBenchmark(id: "RTX 5050", fullHD: 69.3, quadHD: 45.2, ultraHD: 17.0),
        GPUBenchmark(id: "Arc B570", fullHD: 63.5, quadHD: 44.3, ultraHD: 19.6),
        GPUBenchmark(id: "RTX 3060 12GB", fullHD: 61.5, quadHD: 41.9, ultraHD: 22.2),
        GPUBenchmark(id: "RX 6650 XT", fullHD: 64.3, quadHD: 38.0, ultraHD: 19.0),
        GPUBenchmark(id: "RX 6600 XT", fullHD: 62.7, quadHD: 40.7, ultraHD: 17.3),
        GPUBenchmark(id: "RX 6600", fullHD: 51.9, quadHD: 24.8, ultraHD: 14.5),
        GPUBenchmark(id: "RTX 3050", fullHD: 44.6, quadHD: 29.8, ultraHD: 12.6)
    ]
}
