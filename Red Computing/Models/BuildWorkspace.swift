import Foundation

/// A single persisted snapshot keeps saved builds and the independent working draft consistent.
struct BuildWorkspace: Codable, Equatable {
    var savedBuilds: [SavedBuild] = []
    var configuration = BuildConfiguration()
    var activeBuildID: UUID?
}
