import Foundation
import Testing
@testable import Red_Computing

@MainActor
struct ViewModelTests {
    @Test func comparisonKeepsGPUStateWhenSwitchingCategories() {
        let model = ComparisonViewModel()
        #expect(model.comparisonKinds == [.cpu, .gpu])
        model.gpuComparison.resolution = .ultraHD
        model.gpuComparison.selectedGPU = "RX 7800 XT"
        model.kind = .cpu
        #expect(model.parts.count == 2 && model.parts.allSatisfy { $0.kind == .cpu })
        model.kind = .gpu
        #expect(model.parts.count == 2 && model.parts.allSatisfy { $0.kind == .gpu })
        #expect(model.gpuComparison.resolution == .ultraHD)
        #expect(model.gpuComparison.selectedGPU == "RX 7800 XT")
    }

    @Test func rankingsFollowResolutionAndHandleEmptyData() {
        let model = GPUComparisonViewModel(benchmarks: [
            GPUBenchmark(id: "A", fullHD: 80, quadHD: 40, ultraHD: 20),
            GPUBenchmark(id: "B", fullHD: 60, quadHD: 40, ultraHD: 30)
        ])
        #expect(model.rankedResults.map(\.id) == ["A", "B"])
        model.resolution = .ultraHD
        #expect(model.rankedResults.map(\.id) == ["B", "A"])
        #expect(model.selectedGPU == "A")
        let empty = GPUComparisonViewModel(benchmarks: [])
        #expect(empty.rankedResults.isEmpty && empty.selectedGPU.isEmpty)
    }

    @Test func knowledgeSearchAndArticleNavigationRemainConsistent() {
        let model = KnowledgeViewModel()
        model.query = "DDR5"
        #expect(model.articles.map(\.id) == ["compatibility"])
        model.query = "no-matching-article"
        #expect(model.articles.isEmpty)
        model.query = ""
        #expect(model.articles.count == GuideArticle.library.count)
        let detail = ArticleDetailViewModel(article: .compatibility)
        #expect(detail.sourceURL?.absoluteString == GuideArticle.compatibility.source)
        #expect(!detail.relatedArticles.contains { $0.id == detail.article.id })
        #expect(detail.relatedArticles.count == GuideArticle.library.count - 1)
    }

    @Test func componentResourcesPreserveManufacturerAndGuideDestinations() {
        for part in ComponentCatalog.parts {
            let model = PartResourceViewModel(part: part)
            #expect(model.part == part)
            #expect(model.manufacturerURL?.absoluteString == part.resource)
            #expect(model.guideArticle.id == (part.kind == .gpu ? "features" : "compatibility"))
            if case .motherboard(let specs) = part.specifications {
                #expect(model.cpuSupportURL?.absoluteString == specs.cpuSupportURL)
            } else {
                #expect(model.cpuSupportURL == nil)
            }
        }
    }
}
