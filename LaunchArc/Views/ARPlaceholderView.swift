import SwiftUI

struct ARPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "arkit")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            Text("AR View Placeholder")
                .font(.headline)
                .padding()
            Text("This will be replaced with the ARKit view in Phase 2.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ARPlaceholderView()
}
