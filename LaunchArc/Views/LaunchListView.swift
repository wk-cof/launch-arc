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
                        HStack(spacing: 12) {
                            if let logoStr = launch.launchServiceProvider?.logoUrl, let url = URL(string: logoStr) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    } else if phase.error != nil {
                                        Image(systemName: "building.2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.gray)
                                            .frame(width: 50, height: 50)
                                    } else {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            } else {
                                Image(systemName: "building.2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 50)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(launch.name).font(.headline)
                                if let provider = launch.launchServiceProvider?.name {
                                    Text(provider).font(.subheadline).foregroundColor(.primary)
                                }
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
            }
            .navigationTitle("Launches")
            .task {
                await loadLaunches()
            }
        }
    }
    
    private func loadLaunches() async {
        if launches.isEmpty {
            isLoading = true
        }
        errorMessage = nil
        do {
            launches = try await SpaceDevsAPI.shared.fetchUpcomingLaunches()
        } catch {
            if launches.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}

#Preview {
    LaunchListView()
}
