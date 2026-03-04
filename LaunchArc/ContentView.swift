import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        TabView {
            LaunchListView()
            .tabItem {
                Label("Launches", systemImage: "list.dash")
            }

            // Replaced placeholder with actual AR view and injected location manager
            LaunchARView(locationManager: locationManager)
                .edgesIgnoringSafeArea(.all)
            .tabItem {
                Label("AR View", systemImage: "arkit")
            }
            .onAppear {
                locationManager.requestLocationPermissions()
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
