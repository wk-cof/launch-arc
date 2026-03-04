import SwiftUI

struct LaunchListView: View {
    @State private var launches: [Launch] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading launches...")
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage).foregroundColor(.red)
                        Button("Retry") {
                            Task { await loadLaunches() }
                        }
                    }
                } else {
                    List(launches) { launch in
                        VStack(alignment: .leading) {
                            Text(launch.name).font(.headline)
                            if let status = launch.status?.name {
                                Text("Status: \(status)").font(.subheadline).foregroundColor(.secondary)
                            }
                            if let net = launch.net {
                                Text("\(net, style: .date) \(net, style: .time)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Launches")
            .task {
                await loadLaunches()
            }
        }
    }
    
    private func loadLaunches() async {
        isLoading = true
        errorMessage = nil
        do {
            launches = try await SpaceDevsAPI.shared.fetchUpcomingLaunches()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    LaunchListView()
}
