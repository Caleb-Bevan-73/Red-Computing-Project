import Foundation

/// Evaluates the catalog's documented installation path, not a complete physical PC.
/// No state is changed here; unknown information never becomes a passing check.
enum BuildCompatibility {
    static func evaluate(_ configuration: BuildConfiguration, catalog: [Part]) -> [CompatibilityCheck] {
        func part(_ kind: PartKind) -> Part? {
            catalog.first { $0.kind == kind && $0.id == configuration[kind] }
        }
        var checks = PartKind.allCases.compactMap { kind -> CompatibilityCheck? in
            guard !configuration[kind].isEmpty, part(kind) == nil else { return nil }
            return check("missing-\(kind.rawValue)", [kind], .unknown, "\(kind.title): the saved component is unavailable in this catalog.")
        }
        checks.append(cpuBoard(cpu: part(.cpu), board: part(.motherboard)))
        checks += memory(cpu: part(.cpu), board: part(.motherboard), ram: part(.ram))
        checks.append(storage(board: part(.motherboard), drive: part(.storage)))
        checks.append(graphics(cpu: part(.cpu), board: part(.motherboard), gpu: part(.gpu)))
        checks += power(cpu: part(.cpu), gpu: part(.gpu), board: part(.motherboard), psu: part(.psu))
        checks.append(check("physical", [], .unknown,
                            "Case dimensions, ATX motherboard/PSU mounting, GPU and cable clearance, CPU cooling, and front-panel connections are not checked. This is not a fully verified PC."))
        return checks
    }

    static func checks(for candidate: Part, in configuration: BuildConfiguration, catalog: [Part]) -> [CompatibilityCheck] {
        var proposed = configuration
        proposed[candidate.kind] = candidate.id
        return evaluate(proposed, catalog: catalog).filter { $0.kinds.contains(candidate.kind) }
    }

    private static func check(_ id: String, _ kinds: Set<PartKind>, _ status: CompatibilityStatus, _ message: String) -> CompatibilityCheck {
        CompatibilityCheck(id: id, kinds: kinds, status: status, message: message)
    }

    private static func cpuBoard(cpu: Part?, board: Part?) -> CompatibilityCheck {
        let kinds: Set<PartKind> = [.cpu, .motherboard]
        guard let cpu, let board,
              case .cpu(let processor) = cpu.specifications,
              case .motherboard(let motherboard) = board.specifications else {
            return check("cpu-board", kinds, .unknown, "CPU/motherboard: select both parts with documented specifications.")
        }
        guard processor.socket == motherboard.socket else {
            return check("cpu-board", kinds, .incompatible, "\(cpu.name) uses \(processor.socket); \(board.name) uses \(motherboard.socket). Remove or replace the conflicting part.")
        }
        guard let bios = motherboard.supportedCPUs[cpu.id] else {
            return check("cpu-board", kinds, .unknown, "Matching sockets are insufficient: exact CPU support on this \(motherboard.chipset) board has not been documented.")
        }
        switch bios {
        case .allVersions:
            return check("cpu-board", kinds, .compatible, "CPU/motherboard: \(processor.socket) and \(motherboard.chipset); ASUS lists this exact CPU with all BIOS versions.")
        case .minimum(let version):
            return check("cpu-board", kinds, .conditional, "CPU/motherboard: exact CPU supported on \(motherboard.chipset) with BIOS \(version) or later. Installed BIOS is unknown. Confirm it and follow ASUS update instructions before assembly.")
        }
    }

    private static func memory(cpu: Part?, board: Part?, ram: Part?) -> [CompatibilityCheck] {
        let kinds: Set<PartKind> = [.cpu, .motherboard, .ram]
        guard let cpu, let board, let ram,
              case .cpu(let processor) = cpu.specifications,
              case .motherboard(let motherboard) = board.specifications,
              case .ram(let kit) = ram.specifications else {
            return [check("memory", kinds, .unknown, "RAM: select a CPU, motherboard, and memory kit to check generation, slots, and capacity.")]
        }
        guard kit.generation == processor.memoryGeneration, kit.generation == motherboard.memoryGeneration else {
            return [check("memory", kinds, .incompatible, "RAM generation does not match the CPU and motherboard. DDR4 and DDR5 are not interchangeable.")]
        }
        guard kit.modules > 0, kit.modules <= motherboard.memorySlots,
              kit.capacityGB > 0, kit.capacityGB <= min(processor.maximumMemoryGB, motherboard.maximumMemoryGB) else {
            return [check("memory", kinds, .incompatible, "The RAM kit exceeds the available DIMM slots or CPU/motherboard capacity limit.")]
        }
        let withinSpeed = kit.modules == 2 && kit.speed <= min(processor.twoModuleSpeed, motherboard.memorySpeed)
        return [
            check("memory", kinds, withinSpeed ? .compatible : .conditional,
                  "Basic RAM check: \(kit.modules) modules, \(kit.capacityGB) GB \(kit.generation); limit \(min(processor.maximumMemoryGB, motherboard.maximumMemoryGB)) GB, \(motherboard.memorySlots) slots. \(withinSpeed ? "4800 MT/s is within documented two-module speeds. Install in A2/B2." : "Speed for this module configuration needs manual verification.")"),
            check("memory-qualification", kinds, .unknown,
                  "Exact kit QVL qualification is unverified. \(kit.profile) is the kit’s advertised profile; this board advertises \(motherboard.memoryProfile). Basic compatibility does not guarantee profile timings or stability. Start with automatic defaults and verify the exact kit with the manufacturer.")
        ]
    }

    private static func storage(board: Part?, drive: Part?) -> CompatibilityCheck {
        let kinds: Set<PartKind> = [.motherboard, .storage]
        guard let board, let drive,
              case .motherboard(let motherboard) = board.specifications,
              case .storage(let storage) = drive.specifications else {
            return check("storage", kinds, .unknown, "Storage: select a motherboard and drive to check interface and slot size.")
        }
        guard storage.interface == motherboard.storageInterface,
              motherboard.storageFormFactors.contains(storage.formFactor) else {
            return check("storage", kinds, .incompatible, "The drive interface or form factor does not fit the documented motherboard connection.")
        }
        return check("storage", kinds, .conditional,
                     "\(storage.formFactor) \(storage.interface) fits \(motherboard.recommendedStorageSlot). This one-drive build assumes that slot is free. \(motherboard.installationNote)")
    }

    private static func graphics(cpu: Part?, board: Part?, gpu: Part?) -> CompatibilityCheck {
        let kinds: Set<PartKind> = [.cpu, .motherboard, .gpu]
        guard let cpu, let board, let gpu,
              case .motherboard(let motherboard) = board.specifications,
              case .gpu(let graphics) = gpu.specifications,
              motherboard.supportedCPUs[cpu.id] != nil else {
            return check("graphics-slot", kinds, .unknown, "GPU interface: requires a documented CPU/motherboard pairing and GPU specifications.")
        }
        guard motherboard.gpuSlotLanes >= graphics.pcieLanes else {
            return check("graphics-slot", kinds, .conditional, "The documented slot has fewer lanes than the GPU. Verify reduced-bandwidth operation.")
        }
        return check("graphics-slot", kinds, .compatible,
                     "GPU interface: PCIe \(graphics.pcieGeneration).0 x\(graphics.pcieLanes) works in the primary PCIe \(motherboard.gpuSlotGeneration).0 x\(motherboard.gpuSlotLanes) slot, negotiating the lower generation. Physical card fit remains unchecked.")
    }

    private static func power(cpu: Part?, gpu: Part?, board: Part?, psu: Part?) -> [CompatibilityCheck] {
        var result: [CompatibilityCheck] = []
        let powerKinds: Set<PartKind> = [.cpu, .gpu, .psu]
        if let cpu, let gpu, let psu,
           case .cpu(let processor) = cpu.specifications,
           case .gpu(let graphics) = gpu.specifications,
           case .psu(let supply) = psu.specifications {
            // Planning policy, not a manufacturer measurement: 100 W for board, one kit,
            // one drive, fans and USB, plus 25% reserve. Never undercut GPU PSU guidance.
            let estimated = ((processor.powerBudgetWatts + graphics.boardPowerWatts + 100) * 125 + 99) / 100
            let target = max(estimated, graphics.recommendedPSUWatts)
            let meetsGuidance = supply.watts >= graphics.recommendedPSUWatts
                && (graphics.minimum12VAmps == 0 || supply.twelveVoltAmps > graphics.minimum12VAmps)
            result.append(check("power-budget", powerKinds, meetsGuidance ? .conditional : .incompatible,
                                "\(supply.watts) W PSU; planning target \(target) W. GPU guidance: at least \(graphics.recommendedPSUWatts) W\(graphics.minimum12VAmps > 0 ? " and >54 A on +12 V" : ""). Estimate: (\(processor.powerBudgetWatts) W CPU + \(graphics.boardPowerWatts) W GPU + 100 W other parts) × 1.25, rounded up, or GPU guidance if higher. \(processor.powerBudgetNote) \(supply.watts < target ? "Below the planning target; choose more capacity." : "Meets the planning target.") Reference GPU specifications only; partner cards, extra devices and tuning require a fresh check."))
            let native = graphics.supports16PinCable && supply.native16PinWatts >= 300
            let eightPin = supply.eightPinGPUConnectors >= graphics.eightPinConnectors
            result.append(check("gpu-power", [.gpu, .psu], native || eightPin ? .conditional : .incompatible,
                                native
                                ? "GPU power: use the supplied native 600 W 12V-2x6 cable for the reference RTX 4070 SUPER’s 16-pin input; fully seat it. Confirm the exact partner card connector."
                                : "GPU power: needs \(graphics.eightPinConnectors) PCIe 8-pin connectors; supply path provides \(supply.eightPinGPUConnectors). For these RMe units use the included PSU-side 12V-2x6 to dual GPU-side 6+2 cable. Never substitute EPS cables. Confirm the exact card."))
        } else {
            result.append(check("power-budget", powerKinds, .unknown, "Power budget and GPU cables: select a CPU, GPU and PSU with documented specifications. An incomplete build has no confirmed power recommendation."))
        }
        if let board, let psu,
           case .motherboard(let motherboard) = board.specifications,
           case .psu(let supply) = psu.specifications {
            let enough = supply.atx24PinConnectors >= 1 && supply.epsConnectors >= motherboard.epsConnectors
            result.append(check("board-power", [.motherboard, .psu], enough ? .compatible : .incompatible,
                                "Motherboard power: \(motherboard.powerConnectionNote) PSU provides \(supply.atx24PinConnectors) ATX and \(supply.epsConnectors) EPS cables; GPU power uses a separate PSU port."))
        } else {
            result.append(check("board-power", [.motherboard, .psu], .unknown, "Motherboard power: select a board and PSU to check ATX and EPS connections."))
        }
        return result
    }
}
