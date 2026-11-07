import Foundation
import Testing
@testable import Red_Computing

@MainActor
struct ComponentBuildTests {
    private func fullBuild(cpu: String = "7600", gpu: String = "7800xt") -> BuildConfiguration {
        BuildConfiguration(cpuID: cpu, gpuID: gpu,
                           motherboardID: cpu == "7600" ? "tuf-b650-plus-wifi" : "tuf-z790-plus-wifi",
                           ramID: "KF548C38BBK2-32", storageID: "MZ-V9P1T0BW", psuID: "CP-9020295")
    }

    private func checks(_ build: BuildConfiguration, catalog: [Part]? = nil) -> [CompatibilityCheck] {
        BuildCompatibility.evaluate(build, catalog: catalog ?? ComponentCatalog.parts)
    }

    private func replacing(_ kind: PartKind, with specs: ComponentSpecifications, in build: BuildConfiguration) -> [Part] {
        ComponentCatalog.parts.map { part in
            var copy = part
            if part.id == build[kind] { copy.specifications = specs }
            return copy
        }
    }

    @Test func catalogHasExactlyTwoPerCategoryAndEveryPlatformHasAPath() {
        for kind in PartKind.allCases {
            #expect(ComponentCatalog.parts.filter { $0.kind == kind }.count == 2)
        }
        #expect(Set(ComponentCatalog.parts.map(\.id)).count == ComponentCatalog.parts.count)
        for cpu in ["7600", "14600k"] {
            for gpu in ["7800xt", "4070s"] {
                for ram in ComponentCatalog.parts.filter({ $0.kind == .ram }) {
                    for drive in ComponentCatalog.parts.filter({ $0.kind == .storage }) {
                        for psu in ComponentCatalog.parts.filter({ $0.kind == .psu }) {
                            var build = fullBuild(cpu: cpu, gpu: gpu)
                            build.ramID = ram.id
                            build.storageID = drive.id
                            build.psuID = psu.id
                            let result = checks(build)
                            #expect(!result.contains { $0.status == .incompatible })
                            #expect(result.first { $0.id == "memory" }?.status == .compatible)
                            #expect(result.first { $0.id == "board-power" }?.status == .compatible)
                            #expect(result.first { $0.id == "graphics-slot" }?.status == .compatible)
                            #expect(result.first { $0.id == "power-budget" }?.status == .conditional)
                            #expect(result.first { $0.id == "physical" }?.status == .unknown)
                        }
                    }
                }
            }
        }
    }

    @Test func exactCPUAndBIOSSupportAreDistinguished() {
        let amd = checks(fullBuild())
        #expect(amd.first { $0.id == "cpu-board" }?.status == .compatible)
        let intel = checks(fullBuild(cpu: "14600k"))
        #expect(intel.first { $0.id == "cpu-board" }?.status == .conditional)
        #expect(intel.first { $0.id == "cpu-board" }?.message.contains("1205") == true)
        var mismatch = fullBuild()
        mismatch.motherboardID = "tuf-z790-plus-wifi"
        #expect(checks(mismatch).first { $0.id == "cpu-board" }?.status == .incompatible)
        mismatch = fullBuild(cpu: "14600k")
        mismatch.motherboardID = "tuf-b650-plus-wifi"
        #expect(checks(mismatch).first { $0.id == "cpu-board" }?.status == .incompatible)
        let missingSpecs = replacing(.cpu, with: .unknown, in: fullBuild())
        #expect(checks(fullBuild(), catalog: missingSpecs).first { $0.id == "cpu-board" }?.status == .unknown)
    }

    @Test func memoryGenerationModuleCountCapacityAndProfilesAreChecked() {
        let build = fullBuild()
        for kit in [
            MemorySpecifications(generation: "DDR4", modules: 2, capacityGB: 32, speed: 3200, profile: "XMP"),
            MemorySpecifications(generation: "DDR5", modules: 8, capacityGB: 64, speed: 4800, profile: "XMP"),
            MemorySpecifications(generation: "DDR5", modules: 2, capacityGB: 256, speed: 4800, profile: "XMP")
        ] {
            #expect(checks(build, catalog: replacing(.ram, with: .ram(kit), in: build))
                .first { $0.id == "memory" }?.status == .incompatible)
        }
        let fast = MemorySpecifications(generation: "DDR5", modules: 2, capacityGB: 32, speed: 6000, profile: "XMP")
        #expect(checks(build, catalog: replacing(.ram, with: .ram(fast), in: build))
            .first { $0.id == "memory" }?.status == .conditional)
        #expect(checks(build).first { $0.id == "memory-qualification" }?.status == .unknown)
    }

    @Test func storageConnectionsAndPowerRequirementsAreChecked() {
        let build = fullBuild()
        for drive in [
            StorageSpecifications(interface: "SATA", formFactor: "M.2 2280", capacityGB: 1000),
            StorageSpecifications(interface: "PCIe NVMe", formFactor: "M.2 22110", capacityGB: 1000)
        ] {
            #expect(checks(build, catalog: replacing(.storage, with: .storage(drive), in: build))
                .first { $0.id == "storage" }?.status == .incompatible)
        }
        let undersized = PowerSupplySpecifications(watts: 650, twelveVoltAmps: 54, atx24PinConnectors: 1,
                                                  epsConnectors: 1, eightPinGPUConnectors: 1, native16PinWatts: 0)
        let result = checks(build, catalog: replacing(.psu, with: .psu(undersized), in: build))
        for id in ["power-budget", "gpu-power", "board-power"] {
            #expect(result.first { $0.id == id }?.status == .incompatible)
        }
        #expect(checks(build).first { $0.id == "power-budget" }?.message.contains("100 W other parts") == true)
        #expect(checks(build).first { $0.id == "storage" }?.status == .conditional)
    }

    @Test func incompleteAndUnknownPartsDoNotPassChecks() {
        let result = checks(BuildConfiguration())
        #expect(result.allSatisfy { $0.status == .unknown })
        var build = fullBuild()
        build.ramID = "unknown-kit"
        #expect(checks(build).first { $0.id == "memory" }?.status == .unknown)
        #expect(checks(build).contains { $0.id == "missing-RAM" && $0.status == .unknown })
    }

    @Test func selectionReplacementRemovalAndConflictRecovery() {
        let store = ComponentTestStore()
        let model = MyBuildsViewModel(store: store, catalog: ComponentCatalog.parts)
        model.cpuID = "7600"
        model.select("tuf-z790-plus-wifi", for: .motherboard)
        #expect(model.configuration.motherboardID.isEmpty)
        #expect(model.errorMessage != nil)
        model.select("tuf-b650-plus-wifi", for: .motherboard)
        model.gpuID = "4070s"
        model.select("KF548C38BBK2-32", for: .ram)
        model.select("MZ-V9P1T0BW", for: .storage)
        model.select("CP-9020295", for: .psu)
        #expect(model.selectedParts.count == model.componentKinds.count)
        #expect(model.selectedPart(for: .ram)?.id == "KF548C38BBK2-32")
        for (kind, replacement) in [(PartKind.ram, "KF548C38BBK2-64"), (.storage, "MZ-V9P2T0BW"), (.psu, "CP-9020296")] {
            model.select(replacement, for: kind)
            #expect(model.configuration[kind] == replacement)
            #expect(model.selectedPart(for: kind)?.id == replacement)
            #expect(store.workspace.configuration == model.configuration)
            model.select("", for: kind)
            #expect(model.configuration[kind].isEmpty)
            #expect(model.selectedPart(for: kind) == nil)
            model.select(replacement, for: kind)
        }
        // A persisted conflict remains intact and visible; opening never silently repairs parts.
        store.workspace.configuration = fullBuild()
        store.workspace.configuration.cpuID = "14600k"
        let restored = MyBuildsViewModel(store: store, catalog: ComponentCatalog.parts)
        #expect(restored.configuration.motherboardID == "tuf-b650-plus-wifi")
        #expect(restored.compatibilityChecks.contains { $0.status == .incompatible })
        restored.select("", for: .motherboard)
        restored.select("tuf-z790-plus-wifi", for: .motherboard)
        #expect(!restored.compatibilityChecks.contains { $0.status == .incompatible })
    }

    @Test func newSelectionsSurviveSaveCopyCancelAndRelaunch() throws {
        let suite = "ComponentBuildTests-" + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = BuildStore(defaults: defaults)
        try store.save(BuildWorkspace(configuration: fullBuild()))
        let model = MyBuildsViewModel(store: store, catalog: ComponentCatalog.parts)
        model.save()
        model.buildName = "Build A"
        model.submitName()
        let original = try #require(model.savedBuilds.first)
        model.select("KF548C38BBK2-64", for: .ram)
        model.newBuild()
        model.cancelSwitch()
        #expect(model.configuration.ramID == "KF548C38BBK2-64" && model.hasUnsavedChanges)
        #expect(model.savedBuilds.first == original)
        model.saveAsNew()
        model.buildName = "Build B"
        model.submitName()
        #expect(model.savedBuilds.count == 2 && model.savedBuilds[0] == original)
        #expect(model.activeBuildID != original.id)
        model.select("MZ-V9P2T0BW", for: .storage)
        model.save()
        let restored = MyBuildsViewModel(store: BuildStore(defaults: defaults), catalog: ComponentCatalog.parts)
        #expect(restored.savedBuilds == model.savedBuilds)
        #expect(restored.configuration == model.configuration)
        restored.newBuild()
        #expect(restored.configuration == BuildConfiguration())
        restored.openBuild(original.id)
        #expect(restored.configuration == original.configuration)
    }

    @Test func versionOneSavedJSONLoadsWithNewSelectionsUnset() throws {
        let id = UUID()
        let legacy: [String: Any] = [
            "savedBuilds": [["id": id.uuidString, "name": "Old build", "configuration": ["cpuID": "7600", "gpuID": "4070s"]]],
            "configuration": ["cpuID": "7600", "gpuID": "4070s"],
            "activeBuildID": id.uuidString
        ]
        let suite = "LegacyComponentTests-" + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(try JSONSerialization.data(withJSONObject: legacy), forKey: "buildWorkspace.v1")
        let model = MyBuildsViewModel(store: BuildStore(defaults: defaults), catalog: ComponentCatalog.parts)
        #expect(model.storageAvailable)
        #expect(model.configuration == BuildConfiguration(cpuID: "7600", gpuID: "4070s"))
        #expect(model.savedBuilds.first?.configuration == model.configuration)
        #expect(!model.hasUnsavedChanges)
        model.newBuild()
        model.openBuild(id)
        #expect(model.cpuID == "7600" && model.configuration.ramID.isEmpty)
    }
}

@MainActor
private final class ComponentTestStore: BuildStoring {
    var workspace = BuildWorkspace()
    func load() throws -> BuildWorkspace { workspace }
    func save(_ workspace: BuildWorkspace) throws { self.workspace = workspace }
}
