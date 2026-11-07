import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MyBuildsView()
            }
            .tabItem { Label("My Builds", systemImage: "pc") }

            NavigationStack {
                ComparisonView()
            }
            .tabItem { Label("Compare", systemImage: "chart.bar.xaxis") }

            NavigationStack {
                KnowledgeView()
            }
            .tabItem { Label("Learn", systemImage: "books.vertical") }
        }
        .tint(WorkshopTheme.accent)
    }
}

#Preview {
    ContentView()
}
