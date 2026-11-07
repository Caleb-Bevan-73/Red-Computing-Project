import Foundation
import Observation

@MainActor
@Observable
final class MyBuildsViewModel {
    private let store: any BuildStoring
    private let catalog: [Part]
    private var workspace = BuildWorkspace()
    private(set) var storageAvailable = false
    var errorMessage: String?
    var showingUnsavedChanges = false
    var showingNamePrompt = false
    var buildName = ""
    private var pendingSwitch: SwitchAction?
    private var namingAction: NamingAction?

    private enum SwitchAction {
        case newBuild
        case open(UUID)
    }

    private enum NamingAction {
        case save
        case copy
        case saveAndContinue
    }

    convenience init(defaults: UserDefaults = .standard) {
        self.init(store: BuildStore(defaults: defaults), catalog: ComponentCatalog.parts)
    }

    convenience init(defaults: UserDefaults = .standard, catalog: [Part]) {
        self.init(store: BuildStore(defaults: defaults), catalog: catalog)
    }

    init(store: any BuildStoring, catalog: [Part]) {
        self.store = store
        self.catalog = catalog
        do {
            workspace = try store.load()
            // Keep the established behavior for stale IDs in the working draft.
            workspace.configuration = validDraft(workspace.configuration)
            storageAvailable = true
        } catch {
            errorMessage = "Could not load saved builds. \(error.localizedDescription)"
        }
    }

    var savedBuilds: [SavedBuild] { workspace.savedBuilds }
    var activeBuildID: UUID? { workspace.activeBuildID }
    var configuration: BuildConfiguration { workspace.configuration }
    var activeBuild: SavedBuild? { savedBuilds.first { $0.id == activeBuildID } }
    var activeBuildName: String { activeBuild?.name ?? "New Build" }
    var hasUnsavedChanges: Bool {
        configuration != (activeBuild?.configuration ?? BuildConfiguration())
    }
    var canSubmitName: Bool {
        !buildName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var cpuID: String {
        get { configuration.cpuID }
        set {
            select(newValue, for: .cpu)
        }
    }

    var gpuID: String {
        get { configuration.gpuID }
        set {
            select(newValue, for: .gpu)
        }
    }

    var componentKinds: [PartKind] { PartKind.allCases }

    var selectedParts: [Part] {
        componentKinds.compactMap { selectedPart(for: $0) }
    }

    func selectedPart(for kind: PartKind) -> Part? {
        catalog.first { $0.kind == kind && $0.id == configuration[kind] }
    }

    var compatibilityChecks: [CompatibilityCheck] {
        BuildCompatibility.evaluate(configuration, catalog: catalog)
    }

    func options(for kind: PartKind) -> [PartOption] {
        catalog.filter { $0.kind == kind }.map { part in
            PartOption(part: part, checks: BuildCompatibility.checks(for: part, in: configuration, catalog: catalog))
        }
    }

    func select(_ id: String, for kind: PartKind) {
        // Removal always works, including recovery from a conflicting saved configuration.
        if !id.isEmpty {
            guard let option = options(for: kind).first(where: { $0.id == id }) else {
                errorMessage = "This component is unavailable. Your current selection has been kept."
                return
            }
            guard option.canSelect else {
                errorMessage = option.checks.first { $0.status == .incompatible }?.message
                return
            }
        }
        workspace.configuration[kind] = id
        persistDraft()
    }

    func save() {
        guard storageAvailable else { return }
        if let activeBuild {
            _ = saveSnapshot(name: activeBuild.name, asNew: false)
        } else {
            requestName(for: .save)
        }
    }

    func saveAsNew() {
        guard storageAvailable else { return }
        requestName(for: .copy)
    }

    func newBuild() {
        requestSwitch(to: .newBuild)
    }

    func openBuild(_ id: UUID) {
        requestSwitch(to: .open(id))
    }

    func cancelSwitch() {
        showingUnsavedChanges = false
        pendingSwitch = nil
    }

    func discardAndContinue() {
        showingUnsavedChanges = false
        completeSwitch()
    }

    func saveAndContinue() {
        showingUnsavedChanges = false
        if let activeBuild {
            if saveSnapshot(name: activeBuild.name, asNew: false) {
                completeSwitch()
            } else {
                pendingSwitch = nil
            }
        } else {
            requestName(for: .saveAndContinue)
        }
    }

    func cancelNaming() {
        showingNamePrompt = false
        namingAction = nil
        pendingSwitch = nil
    }

    func submitName() {
        guard let action = namingAction, canSubmitName else { return }
        guard saveSnapshot(name: buildName, asNew: action == .copy) else { return }
        showingNamePrompt = false
        namingAction = nil
        if action == .saveAndContinue {
            completeSwitch()
        }
    }

    func retryLoad() {
        // Retry must never replace work entered after a load failure.
        do {
            let loaded = try store.load()
            workspace.savedBuilds = loaded.savedBuilds
            workspace.activeBuildID = nil
            storageAvailable = true
            errorMessage = nil
        } catch {
            errorMessage = "Could not load saved builds. \(error.localizedDescription)"
        }
    }

    private func requestName(for action: NamingAction) {
        namingAction = action
        buildName = ""
        errorMessage = nil
        showingNamePrompt = true
    }

    private func requestSwitch(to action: SwitchAction) {
        guard storageAvailable else { return }
        pendingSwitch = action
        if hasUnsavedChanges {
            showingUnsavedChanges = true
        } else {
            completeSwitch()
        }
    }

    private func completeSwitch() {
        guard let action = pendingSwitch else { return }
        pendingSwitch = nil
        var candidate = workspace
        switch action {
        case .newBuild:
            candidate.configuration = BuildConfiguration()
            candidate.activeBuildID = nil
        case .open(let id):
            guard let saved = savedBuilds.first(where: { $0.id == id }) else {
                errorMessage = "This saved build could not be found. Your current configuration has been kept."
                return
            }
            guard validDraft(saved.configuration) == saved.configuration else {
                errorMessage = "This build contains components that are no longer in the catalog. Your current configuration has been kept."
                return
            }
            candidate.configuration = saved.configuration
            candidate.activeBuildID = saved.id
        }
        _ = commit(candidate, failure: "Could not open the configuration.")
    }

    private func saveSnapshot(name: String, asNew: Bool) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard storageAvailable, !name.isEmpty else { return false }
        var candidate = workspace
        if !asNew, let index = candidate.savedBuilds.firstIndex(where: { $0.id == activeBuildID }) {
            candidate.savedBuilds[index].configuration = configuration
        } else {
            let build = SavedBuild(id: UUID(), name: name, configuration: configuration)
            candidate.savedBuilds.append(build)
            candidate.activeBuildID = build.id
        }
        return commit(candidate, failure: "Could not save the build.")
    }

    private func commit(_ candidate: BuildWorkspace, failure: String) -> Bool {
        do {
            try store.save(candidate)
            workspace = candidate
            errorMessage = nil
            return true
        } catch {
            errorMessage = "\(failure) Your current configuration has been kept. \(error.localizedDescription)"
            return false
        }
    }

    private func persistDraft() {
        guard storageAvailable else { return }
        // Draft autosaves never change the saved-build snapshots.
        do {
            try store.save(workspace)
            errorMessage = nil
        } catch {
            errorMessage = "Could not keep the working draft on this device. Your edits are still open. \(error.localizedDescription)"
        }
    }

    private func validDraft(_ configuration: BuildConfiguration) -> BuildConfiguration {
        var draft = configuration
        for kind in PartKind.allCases {
            if !catalog.contains(where: { $0.id == draft[kind] && $0.kind == kind }) {
                draft[kind] = ""
            }
        }
        return draft
    }
}
