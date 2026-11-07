import Foundation

struct SavedBuild: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var configuration: BuildConfiguration
}
