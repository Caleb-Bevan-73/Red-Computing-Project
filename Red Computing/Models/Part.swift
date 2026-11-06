import Foundation

struct Part: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: PartKind
    let detail: String
    let technology: String
    let resource: String

    static let catalog: [Part] = [
        Part(id: "7600", name: "Ryzen 5 7600", kind: .cpu,
             detail: "AMD · Ryzen desktop",
             technology: "Explore the Ryzen platform, motherboard requirements, and memory support before selecting your board.",
             resource: "https://www.amd.com/en/gaming/desktops/ryzen-radeon-platforms.html"),
        Part(id: "14600k", name: "Core i5-14600K", kind: .cpu,
             detail: "Intel · LGA1700",
             technology: "Supports DDR4 or DDR5 depending on the motherboard. Check the board’s CPU support list and required BIOS version.",
             resource: "https://www.intel.com/content/www/us/en/support/articles/000092149/processors.html"),
        Part(id: "7800xt", name: "Radeon RX 7800 XT", kind: .gpu,
             detail: "AMD · Radeon graphics",
             technology: "FSR features depend on the game and supported hardware. Upscaling and generated frames are excluded from native raster comparisons.",
             resource: "https://www.amd.com/en/products/graphics/technologies/fidelityfx/super-resolution.html"),
        Part(id: "4070s", name: "GeForce RTX 4070 SUPER", kind: .gpu,
             detail: "NVIDIA · GeForce graphics",
             technology: "DLSS feature support varies by GPU and game. Keep upscaling, frame generation, and ray tracing separate from native raster results.",
             resource: "https://www.nvidia.com/en-us/geforce/technologies/dlss/")
    ]

    static func selected(_ id: String) -> Part? {
        catalog.first { $0.id == id }
    }
}
