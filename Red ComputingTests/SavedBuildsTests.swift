import Foundation
import Testing
@testable import Red_Computing

@MainActor
struct SavedBuildsTests {
    private func makeModel(_ store: MemoryBuildStore) -> MyBuildsViewModel {
        MyBuildsViewModel(store: store, catalog: Part.catalog)
    }

    private func nameAndSave(_ model: MyBuildsViewModel, _ name: String) {
        model.save()
        model.buildName = name
        model.submitName()
    }

    @Test func savedBuildsAreIndependentAndCopiesHaveUniqueIDs() throws {
        let store = MemoryBuildStore()
        let model = makeModel(store)
        model.cpuID = "7600"
        nameAndSave(model, "Build A")
        let a = try #require(model.savedBuilds.first)
        #expect(a.configuration.gpuID.isEmpty)
        model.newBuild()
        #expect(model.configuration == BuildConfiguration())
        model.gpuID = "4070s"
        #expect(model.savedBuilds.first == a)
        model.openBuild(a.id)
        #expect(model.showingUnsavedChanges)
        model.cancelSwitch()
        #expect(model.gpuID == "4070s" && model.hasUnsavedChanges)
        model.openBuild(a.id)
        model.discardAndContinue()
        #expect(model.cpuID == "7600" && model.gpuID.isEmpty)
        model.gpuID = "7800xt"
        #expect(model.savedBuilds.first == a)
        model.save()
        #expect(model.savedBuilds.count == 1)
        #expect(model.savedBuilds[0].configuration.gpuID == "7800xt")
        model.cpuID = "14600k"
        model.saveAsNew()
        model.buildName = "Build A"
        model.submitName()
        #expect(model.savedBuilds.count == 2)
        #expect(Set(model.savedBuilds.map(\.id)).count == 2)
        #expect(model.savedBuilds[0].configuration.cpuID == "7600")
        #expect(model.activeBuildID == model.savedBuilds[1].id)
        #expect(!model.hasUnsavedChanges)
    }

    @Test func namingAndSwitchCancellationPreserveWork() throws {
        let store = MemoryBuildStore()
        let model = makeModel(store)
        nameAndSave(model, "Empty Build")
        let empty = try #require(model.savedBuilds.first)
        #expect(empty.configuration == BuildConfiguration())
        model.newBuild()
        model.cpuID = "7600"
        model.openBuild(empty.id)
        model.saveAndContinue()
        #expect(model.showingNamePrompt)
        model.buildName = "   "
        model.submitName()
        #expect(model.showingNamePrompt && model.savedBuilds.count == 1)
        model.cancelNaming()
        #expect(model.cpuID == "7600" && model.activeBuildID == nil)
        model.openBuild(empty.id)
        model.saveAndContinue()
        model.buildName = "  Partial  "
        model.submitName()
        #expect(model.activeBuildID == empty.id)
        #expect(model.savedBuilds.last?.name == "Partial")
        #expect(model.savedBuilds.last?.configuration.cpuID == "7600")
        model.gpuID = "4070s"
        model.newBuild()
        model.saveAndContinue()
        #expect(model.activeBuildID == nil && model.configuration == BuildConfiguration())
        #expect(model.savedBuilds.first?.configuration.gpuID == "4070s")
    }

    @Test func saveFailuresNeverSwitchOrMutateSavedBuilds() throws {
        let store = MemoryBuildStore()
        let model = makeModel(store)
        model.cpuID = "7600"
        nameAndSave(model, "Original")
        let original = try #require(model.savedBuilds.first)
        model.gpuID = "4070s"
        let draft = model.configuration
        store.failWrites = true
        model.newBuild()
        model.saveAndContinue()
        #expect(model.configuration == draft && model.activeBuildID == original.id)
        #expect(model.savedBuilds.first == original && model.errorMessage != nil)
        model.newBuild()
        model.discardAndContinue()
        #expect(model.configuration == draft)
        model.saveAsNew()
        model.buildName = "Copy"
        model.submitName()
        #expect(model.showingNamePrompt && model.savedBuilds.count == 1)
        model.cancelNaming()
        #expect(model.configuration == draft)
        store.failWrites = false
        model.save()
        #expect(model.savedBuilds[0].configuration == draft)
    }

    @Test func unnamedSaveFailureAndLoadFailurePreserveWork() {
        let store = MemoryBuildStore()
        let model = makeModel(store)
        model.cpuID = "7600"
        model.newBuild()
        model.saveAndContinue()
        model.buildName = "Partial"
        store.failWrites = true
        model.submitName()
        #expect(model.showingNamePrompt && model.savedBuilds.isEmpty)
        #expect(model.cpuID == "7600" && model.activeBuildID == nil)
        model.cancelNaming()
        store.failReads = true
        let failed = makeModel(store)
        #expect(!failed.storageAvailable && failed.errorMessage != nil)
        failed.gpuID = "4070s"
        let diskBefore = store.workspace
        failed.save()
        #expect(store.workspace == diskBefore)
        store.failReads = false
        failed.retryLoad()
        #expect(failed.storageAvailable && failed.gpuID == "4070s")
    }

    @Test func failedOpenPreservesDraft() throws {
        let store = MemoryBuildStore()
        let model = makeModel(store)
        model.cpuID = "7600"
        nameAndSave(model, "A")
        model.gpuID = "4070s"
        let draft = model.configuration
        model.openBuild(UUID())
        model.discardAndContinue()
        #expect(model.configuration == draft && model.errorMessage != nil)
        let unavailable = SavedBuild(id: UUID(), name: "Old parts",
                                     configuration: BuildConfiguration(cpuID: "missing"))
        store.workspace.savedBuilds.append(unavailable)
        let restored = makeModel(store)
        restored.openBuild(unavailable.id)
        restored.discardAndContinue()
        #expect(restored.configuration == draft && restored.errorMessage != nil)
    }

    @Test func localStoreRoundTripMigrationAndCorruption() throws {
        let suite = "SavedBuildTests-" + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("7600", forKey: "selectedCPU")
        let store = BuildStore(defaults: defaults)
        let model = MyBuildsViewModel(store: store, catalog: Part.catalog)
        #expect(model.cpuID == "7600" && model.savedBuilds.isEmpty)
        nameAndSave(model, "Migrated")
        model.gpuID = "7800xt"
        let restored = MyBuildsViewModel(store: BuildStore(defaults: defaults), catalog: Part.catalog)
        #expect(restored.savedBuilds == model.savedBuilds)
        #expect(restored.activeBuildID == model.activeBuildID)
        #expect(restored.configuration == model.configuration && restored.hasUnsavedChanges)
        #expect(restored.savedBuilds[0].configuration.gpuID.isEmpty)
        let invalid = Data("not valid JSON".utf8)
        defaults.set(invalid, forKey: "buildWorkspace.v1")
        let broken = MyBuildsViewModel(store: store, catalog: Part.catalog)
        #expect(!broken.storageAvailable)
        broken.cpuID = "14600k"
        broken.save()
        #expect(defaults.data(forKey: "buildWorkspace.v1") == invalid)
    }
}

@MainActor
private final class MemoryBuildStore: BuildStoring {
    var workspace = BuildWorkspace()
    var failReads = false
    var failWrites = false

    func load() throws -> BuildWorkspace {
        if failReads { throw BuildStoreError.invalidData }
        return workspace
    }

    func save(_ workspace: BuildWorkspace) throws {
        if failWrites { throw BuildStoreError.invalidData }
        self.workspace = workspace
    }
}
