import SwiftUI
import ARKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "rocket")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("LaunchArc Application")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
