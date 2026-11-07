import Foundation

enum ComponentSpecifications: Hashable {
    case unknown
    case cpu(CPUSpecifications)
    case gpu(GPUSpecifications)
    case motherboard(MotherboardSpecifications)
    case ram(MemorySpecifications)
    case storage(StorageSpecifications)
    case psu(PowerSupplySpecifications)
}

struct CPUSpecifications: Hashable {
    let socket: String
    let memoryGeneration: String
    let maximumMemoryGB: Int
    let twoModuleSpeed: Int
    let powerBudgetWatts: Int
    let powerBudgetNote: String
}

struct GPUSpecifications: Hashable {
    let boardPowerWatts: Int
    let recommendedPSUWatts: Int
    let minimum12VAmps: Double
    let pcieGeneration: Int
    let pcieLanes: Int
    let eightPinConnectors: Int
    let supports16PinCable: Bool
}

enum BIOSRequirement: Hashable {
    case allVersions
    case minimum(String)
}

struct MotherboardSpecifications: Hashable {
    let socket: String
    let chipset: String
    let supportedCPUs: [String: BIOSRequirement]
    let cpuSupportURL: String
    let memoryGeneration: String
    let memorySlots: Int
    let maximumMemoryGB: Int
    let memorySpeed: Int
    let memoryProfile: String
    let gpuSlotGeneration: Int
    let gpuSlotLanes: Int
    let storageInterface: String
    let storageFormFactors: [String]
    let recommendedStorageSlot: String
    let installationNote: String
    let epsConnectors: Int
    let powerConnectionNote: String
}

struct MemorySpecifications: Hashable {
    let generation: String
    let modules: Int
    let capacityGB: Int
    let speed: Int
    let profile: String
}

struct StorageSpecifications: Hashable {
    let interface: String
    let formFactor: String
    let capacityGB: Int
}

struct PowerSupplySpecifications: Hashable {
    let watts: Int
    let twelveVoltAmps: Double
    let atx24PinConnectors: Int
    let epsConnectors: Int
    // Two GPU connectors supplied by the included 12V-2x6-to-dual-6+2 cable.
    // This cable and the native 16-pin GPU cable are alternative uses of one PSU port.
    let eightPinGPUConnectors: Int
    let native16PinWatts: Int
}
