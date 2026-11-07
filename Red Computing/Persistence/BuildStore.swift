import Foundation

@MainActor
protocol BuildStoring {
    func load() throws -> BuildWorkspace
    func save(_ workspace: BuildWorkspace) throws
}

enum BuildStoreError: LocalizedError {
    case invalidData

    var errorDescription: String? {
        "The saved build data could not be read. Your current configuration has been kept."
    }
}

@MainActor
final class BuildStore: BuildStoring {
    private let defaults: UserDefaults
    private let key = "buildWorkspace.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() throws -> BuildWorkspace {
        guard let value = defaults.object(forKey: key) else {
            // Migrate the existing editor draft without creating an implicit saved build.
            return BuildWorkspace(configuration: BuildConfiguration(
                cpuID: defaults.string(forKey: "selectedCPU") ?? "",
                gpuID: defaults.string(forKey: "selectedGPU") ?? ""
            ))
        }
        guard let data = value as? Data else { throw BuildStoreError.invalidData }
        let workspace = try JSONDecoder().decode(BuildWorkspace.self, from: data)
        guard Set(workspace.savedBuilds.map(\.id)).count == workspace.savedBuilds.count,
              workspace.savedBuilds.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
              workspace.activeBuildID == nil || workspace.savedBuilds.contains(where: { $0.id == workspace.activeBuildID })
        else { throw BuildStoreError.invalidData }
        return workspace
    }

    func save(_ workspace: BuildWorkspace) throws {
        // Encode completely before replacing the single stored snapshot.
        let data = try JSONEncoder().encode(workspace)
        defaults.set(data, forKey: key)
    }
}
