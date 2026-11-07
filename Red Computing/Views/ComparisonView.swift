import SwiftUI
import Charts

struct ComparisonView: View {
    @State private var viewModel = ComparisonViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageIntroView(eyebrow: "THE PERFORMANCE LAB", title: "An equal playing field.",
                          subtitle: "Native rendering first. Technology features explained separately.", icon: "chart.bar.xaxis")
                Picker("Component type", selection: $viewModel.kind) {
                    ForEach(PartKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.kind == .gpu {
                    GPUComparisonChartView(viewModel: viewModel.gpuComparison)
                } else {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("CPU gaming performance")
                            .font(.title2.bold())
                        Label("Illustrative data · Not measured benchmarks", systemImage: "info.circle")
                            .font(.subheadline.bold())
                            .foregroundStyle(WorkshopTheme.accent)
                        Chart(viewModel.cpuDemoResults) { result in
                            BarMark(x: .value("Sample index", result.score), y: .value("Example component", result.id))
                                .foregroundStyle(WorkshopTheme.accent.gradient)
                                .cornerRadius(5)
                                .annotation(position: .trailing) {
                                    Text(result.score.formatted()).font(.caption.monospacedDigit())
                                }
                        }
                        .chartXScale(domain: 0...115)
                        .chartXAxisLabel("Illustrative relative index")
                        .frame(height: 220)
                        Text("Fictional components demonstrate the chart layout. No test suite, resolution, or measured FPS is attached; these values must not guide a purchase.")
                            .font(.caption).foregroundStyle(.secondary)
                        Divider()
                        Text("Benchmark standard").font(.headline)
                        Text("Native resolution • Ray tracing off • Upscaling off • Frame generation off")
                            .font(.subheadline)
                        Text("CPU comparisons will use a fixed GPU and matching game settings to measure processor impact on frame delivery.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .workshopCard()
                }
                ArticleLinkView(article: .raster)
                Text("Component technology notes").font(.title2.bold())
                ForEach(viewModel.parts) { part in
                    PartResourceView(part: part)
                }
            }
            .padding(24)
            .frame(maxWidth: 850)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Compare")
    }
}
