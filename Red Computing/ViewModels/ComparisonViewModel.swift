import Foundation
import Observation

@MainActor
@Observable
final class ComparisonViewModel {
    var kind: PartKind = .gpu
    private let catalog: [Part]

    // Retain chart state when the GPU view is temporarily removed by the CPU tab.
    let gpuComparison = GPUComparisonViewModel()

    let cpuDemoResults = [
        DemoResult(id: "Example CPU A", score: 100),
        DemoResult(id: "Example CPU B", score: 91),
        DemoResult(id: "Example CPU C", score: 76)
    ]

    convenience init() {
        self.init(catalog: Part.catalog)
    }

    init(catalog: [Part]) {
        self.catalog = catalog
    }

    var parts: [Part] { catalog.filter { $0.kind == kind } }
}
