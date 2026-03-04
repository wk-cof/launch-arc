import SwiftUI

struct LaunchListView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Upcoming Launches will appear here.")
            }
            .navigationTitle("Launches")
        }
    }
}

#Preview {
    LaunchListView()
}
