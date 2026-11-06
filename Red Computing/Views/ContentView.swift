import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                BuildGuideView()
            }
            .tabItem { Label("My build", systemImage: "pc") }

            NavigationStack {
                ComparisonView()
            }
            .tabItem { Label("Compare", systemImage: "chart.bar.xaxis") }

            NavigationStack {
                KnowledgeView()
            }
            .tabItem { Label("Learn", systemImage: "books.vertical") }
        }
        .tint(Workshop.accent)
    }
}

#Preview {
    ContentView()
}
