import Foundation
import Observation

@MainActor
@Observable
final class GPUComparisonViewModel {
    var resolution: GPUResolution = .quadHD
    var selectedGPU: String
    let benchmarks: [GPUBenchmark]
    let architectures = GPUBenchmark.architectures

    convenience init() {
        self.init(benchmarks: GPUBenchmark.snapshot)
    }

    init(benchmarks: [GPUBenchmark]) {
        self.benchmarks = benchmarks
        selectedGPU = benchmarks.first { $0.id == "RTX 4070 Super" }?.id
            ?? benchmarks.first?.id ?? ""
    }

    var rankedResults: [GPUBenchmark] {
        benchmarks.sorted {
            let first = $0.fps(at: resolution)
            let second = $1.fps(at: resolution)
            return first == second ? $0.id < $1.id : first > second
        }
    }
}
