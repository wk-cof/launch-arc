import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var azimuthOffset: Double = 0.0
    @State private var elevationOffset: Double = 0.0

    var body: some View {
        TabView {
            LaunchListView()
            .tabItem {
                Label("Launches", systemImage: "list.dash")
            }

            ZStack {
                LaunchARView(locationManager: locationManager, azimuthOffset: $azimuthOffset, elevationOffset: $elevationOffset)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Debug HUD")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Azimuth Offset: \(azimuthOffset, specifier: "%.1f")°")
                            .font(.headline)
                        Slider(value: $azimuthOffset, in: -180...180, step: 1.0)
                        
                        Text("Elevation Offset: \(elevationOffset, specifier: "%.1f")°")
                            .font(.headline)
                        Slider(value: $elevationOffset, in: -90...90, step: 1.0)
                        
                        Button("Reset") {
                            azimuthOffset = 0.0
                            elevationOffset = 0.0
                        }
                        .padding(.top, 4)
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(12)
                    .padding()
                    .foregroundColor(.white)
                }
                .padding(.bottom, 60) // avoid tab bar overlapping
            }
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
