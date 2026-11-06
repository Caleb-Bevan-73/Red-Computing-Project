import SwiftUI
import Charts

struct GPUComparisonChart: View {
    @State private var resolution: GPUResolution = .quadHD
    @State private var selectedGPU = "RTX 4070 Super"

    private var rankedResults: [GPUBenchmark] {
        GPUBenchmark.snapshot.sorted {
            let first = $0.fps(at: resolution)
            let second = $1.fps(at: resolution)
            return first == second ? $0.id < $1.id : first > second
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("GPU benchmarks hierarchy").font(.title2.bold())
            Text("Raster gaming · 2026").font(.headline).foregroundStyle(.secondary)
            Picker("Resolution", selection: $resolution) {
                ForEach(GPUResolution.allCases) { resolution in
                    Text(resolution.rawValue).tag(resolution)
                }
            }
            .pickerStyle(.segmented)

            Text("Native resolution · Higher FPS is better").font(.subheadline)
            Picker("Highlight GPU", selection: $selectedGPU) {
                ForEach(GPUBenchmark.snapshot) { result in
                    Text(result.id).tag(result.id)
                }
            }

            // Keep architecture columns readable on narrow windows.
            ScrollView(.horizontal) {
                Chart(GPUBenchmark.snapshot) { result in
                    PointMark(
                        x: .value("Architecture", result.architecture),
                        y: .value("Frames per second", result.fps(at: resolution))
                    )
                    .foregroundStyle(by: .value("Architecture", result.architecture))
                    .symbolSize(result.id == selectedGPU ? 130 : 35)
                    .opacity(result.id == selectedGPU ? 1 : 0.65)
                    .annotation(position: .top, alignment: .center) {
                        if result.id == selectedGPU {
                            VStack(spacing: 2) {
                                Text(result.id).bold()
                                Text("\(result.fps(at: resolution).formatted(.number.precision(.fractionLength(1)))) FPS")
                            }
                            .font(.caption)
                            .padding(6)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .accessibilityLabel(result.id)
                    .accessibilityValue("\(result.fps(at: resolution).formatted()) frames per second")
                }
                .chartXScale(domain: GPUBenchmark.architectures)
                .chartYScale(domain: 0...240)
                .chartForegroundStyleScale(
                    domain: GPUBenchmark.architectures,
                    range: [Color(red: 0.46, green: 0.58, blue: 0.20), .red, .green, .purple, .blue]
                )
                .chartYAxis {
                    AxisMarks(position: .leading, values: .stride(by: 20)) {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel("Frames per second")
                .chartLegend(.hidden)
                .frame(minWidth: 720)
                .frame(height: 440)
                .padding(.top, 8)
            }
            Text("Choose a GPU to show its label. Scroll horizontally to see every architecture.")
                .font(.caption).foregroundStyle(.secondary)

            GPUBenchmarkSource()
            Divider()
            Text("\(resolution.rawValue) rankings").font(.headline)
            Text("All 48 GPUs · FPS").font(.caption).foregroundStyle(.secondary)
            LazyVStack(spacing: 0) {
                ForEach(rankedResults) { result in
                    Button {
                        selectedGPU = result.id
                    } label: {
                        HStack {
                            Text(result.id)
                            Spacer(minLength: 12)
                            Text(result.fps(at: resolution), format: .number.precision(.fractionLength(1)))
                                .monospacedDigit().bold()
                        }
                        .font(.subheadline)
                        .padding(10)
                        .background(selectedGPU == result.id ? Workshop.accent.opacity(0.12) : Color.clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(result.id), \(result.fps(at: resolution).formatted()) frames per second")
                    .accessibilityAddTraits(selectedGPU == result.id ? .isSelected : [])
                }
            }
        }
        .workshopCard()
    }
}

private struct GPUBenchmarkSource: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tom’s Hardware · June 24, 2026 snapshot")
                .font(.subheadline.bold())
            Text("Geometric mean across 11 raster games on a Ryzen 7 9800X3D. High/Ultra settings vary by game. Ray tracing, upscaling, and frame generation are off.")
            Text("Values follow the published rasterization table; some chart-image values differ. Retrieved November 6, 2026. This snapshot does not update automatically.")
            if let url = URL(string: "https://www.tomshardware.com/reviews/gpu-hierarchy,4388.html") {
                Link(destination: url) {
                    Label("View source and testing details", systemImage: "arrow.up.right.square")
                }
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
