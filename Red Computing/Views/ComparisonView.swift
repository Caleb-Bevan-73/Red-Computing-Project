import SwiftUI
import Charts

struct ComparisonView: View {
    @State private var kind: PartKind = .gpu

    private var results: [DemoResult] {
        [DemoResult(id: "Example CPU A", score: 100), DemoResult(id: "Example CPU B", score: 91), DemoResult(id: "Example CPU C", score: 76)]
    }
    private var parts: [Part] { Part.catalog.filter { $0.kind == kind } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageIntro(eyebrow: "THE PERFORMANCE LAB", title: "An equal playing field.",
                          subtitle: "Native rendering first. Technology features explained separately.", icon: "chart.bar.xaxis")
                Picker("Component type", selection: $kind) {
                    ForEach(PartKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                if kind == .gpu {
                    GPUComparisonChart()
                } else {
                VStack(alignment: .leading, spacing: 18) {
                    Text(kind == .gpu ? "Rasterization performance" : "CPU gaming performance")
                        .font(.title2.bold())
                    Label("Illustrative data · Not measured benchmarks", systemImage: "info.circle")
                        .font(.subheadline.bold())
                        .foregroundStyle(Workshop.accent)
                    Chart(results) { result in
                        BarMark(x: .value("Sample index", result.score), y: .value("Example component", result.id))
                            .foregroundStyle(Workshop.accent.gradient)
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
                    Text(kind == .cpu
                         ? "CPU comparisons will use a fixed GPU and matching game settings to measure processor impact on frame delivery."
                         : "GPU comparisons will use a fixed CPU, matching game settings, and a shared resolution.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .workshopCard()
                }
                ArticleLink(article: .raster)
                Text("Component technology notes").font(.title2.bold())
                ForEach(parts) { part in
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
