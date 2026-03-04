import SwiftUI

struct SettingsView: View {
    @State private var useNightMode = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display")) {
                    Toggle("Night Vision Mode", isOn: $useNightMode)
                }
                
                Section(header: Text("About")) {
                    Text("LaunchArc V1.0 (Draft)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
