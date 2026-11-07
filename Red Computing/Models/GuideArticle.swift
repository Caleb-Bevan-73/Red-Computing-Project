import Foundation

struct GuideArticle: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let icon: String
    let summary: String
    let body: String
    let source: String
    let sourceTitle: String

    static let library: [GuideArticle] = [
        GuideArticle(id: "compatibility", title: "Start with the platform", category: "BUILD ESSENTIALS",
                     icon: "cpu", summary: "Sockets, motherboards, memory, and BIOS.",
                     body: "Choose a CPU and then check the exact motherboard’s CPU support list. A matching socket alone does not establish compatibility: chipset support and BIOS version matter too.\n\nBuy the memory type supported by the board. DDR4 and DDR5 are not interchangeable. Before assembling, consult the motherboard manual for memory slot placement, power connections, and first-boot instructions.",
                     source: "https://www.intel.com/content/www/us/en/support/articles/000092149/processors.html",
                     sourceTitle: "Intel platform compatibility"),
        GuideArticle(id: "raster", title: "Read a rasterization chart", category: "PERFORMANCE",
                     icon: "chart.bar.xaxis", summary: "Compare native rendering on equal terms.",
                     body: "Rasterization results describe performance with ray tracing disabled. For a native-resolution comparison, disable upscaling, dynamic resolution, and frame generation too.\n\nCompare results from the same test suite, resolution, quality preset, and system configuration. Average FPS describes throughput; 1% lows help reveal uneven frame delivery. A relative index is only meaningful within its own dataset.\n\nCPU gaming tests measure how the processor affects frame delivery with a controlled GPU. They are not a measure of a CPU’s own rasterization capability. GPU tests should control the CPU and other system components.",
                     source: "https://www.nvidia.com/en-us/geforce/technologies/dlss/",
                     sourceTitle: "Understand DLSS features"),
        GuideArticle(id: "features", title: "Beyond native frames", category: "TECHNOLOGY",
                     icon: "sparkles", summary: "Upscaling, frame generation, and feature support.",
                     body: "Upscaling reconstructs an output image from a lower internal resolution. Frame generation adds synthesized frames. These can change the experience, but their FPS figures should not be mixed into a native-rendering chart.\n\nCheck the exact GPU generation and game for feature support. A vendor technology name does not guarantee every version or feature works on every card.",
                     source: "https://www.amd.com/en/products/graphics/technologies/fidelityfx/super-resolution.html",
                     sourceTitle: "Explore AMD FSR"),
        GuideArticle(id: "checklist", title: "Before you order", category: "BUILD ESSENTIALS",
                     icon: "checklist", summary: "The physical checks a parts list cannot skip.",
                     body: "Check GPU length and thickness against your case, including space used by front radiators. Confirm CPU cooler height, socket mounting support, and RAM clearance.\n\nFollow the graphics-card manufacturer’s power-supply and connector requirements for your exact model. Check the motherboard form factor, storage slots, and front-panel connections.\n\nThe app checks documented component relationships, BIOS conditions, memory limits, storage slots, and estimated power needs. Case fit, cooling, exact memory-kit qualification, and partner GPU variations still need manual verification. Use the exact component manuals before ordering.",
                     source: "https://www.amd.com/en/gaming/desktops/ryzen-radeon-platforms.html",
                     sourceTitle: "Explore the Ryzen and Radeon platform")
    ]

    static let compatibility = library[0]
    static let raster = library[1]
    static let features = library[2]
    static let checklist = library[3]
}
