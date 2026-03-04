import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LaunchListView()
            .tabItem {
                Label("Launches", systemImage: "list.dash")
            }

            ARPlaceholderView()
            .tabItem {
                Label("AR View", systemImage: "arkit")
            }

            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    ContentView()
}
