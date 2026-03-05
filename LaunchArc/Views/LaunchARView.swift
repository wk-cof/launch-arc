import SwiftUI
import RealityKit
import ARKit
import CoreLocation

#if targetEnvironment(simulator)
struct LaunchARView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var azimuthOffset: Double
    @Binding var elevationOffset: Double
    
    var body: some View {
        VStack {
            Image(systemName: "arkit")
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .padding()
            Text("AR View is not supported on Simulator.\nPlease run on a physical device.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .onAppear {
            // Still run rendering math for debug output
            if let location = locationManager.location {
                let observer = LocationContext(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    altitude: location.altitude
                )
                var moonAzEl = AstroEngine.calculateMoonPosition(date: Date(), observer: observer)
                moonAzEl.azimuth += azimuthOffset
                moonAzEl.elevation += elevationOffset
                print("🌑 Simulator Moon Azimuth: \(moonAzEl.azimuth), Elevation: \(moonAzEl.elevation)")
                
                var sunAzEl = AstroEngine.calculateSunPosition(date: Date(), observer: observer)
                sunAzEl.azimuth += azimuthOffset
                sunAzEl.elevation += elevationOffset
                print("☀️ Simulator Sun Azimuth: \(sunAzEl.azimuth), Elevation: \(sunAzEl.elevation)")
            }
        }
    }
}
#else
struct LaunchARView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var azimuthOffset: Double
    @Binding var elevationOffset: Double
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading // Crucial: Aligns ARKit to True North
        arView.session.run(config)
        
        // Add a coaching overlay to ask the user to move the phone to calibrate the compass/sensors
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.goal = .tracking
        arView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arView.heightAnchor)
        ])
        
        // Save the arView instance to the coordinator so we can update it
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard let location = locationManager.location else { return }
        
        let observerContext = LocationContext(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude
        )
        
        // Render the Celestial Bodies
        context.coordinator.renderMoon(observer: observerContext, azimuthOffset: azimuthOffset, elevationOffset: elevationOffset)
        context.coordinator.renderSun(observer: observerContext, azimuthOffset: azimuthOffset, elevationOffset: elevationOffset)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        weak var arView: ARView?
        private var moonAnchor: AnchorEntity?
        private var sunAnchor: AnchorEntity?
        
        func renderMoon(observer: LocationContext, azimuthOffset: Double, elevationOffset: Double) {
            guard let arView = arView else { return }
            
            // 1. Calculate the math
            var azEl = AstroEngine.calculateMoonPosition(date: Date(), observer: observer)
            
            // Apply Dynamic Calibration Offsets
            azEl.azimuth += azimuthOffset
            azEl.elevation += elevationOffset
            
            print("🌑 Moon Azimuth: \(azEl.azimuth), Elevation: \(azEl.elevation)")
            
            // 2. Transform Math to ARKit Native Coordinate Space (500 meters away)
            let transform = ARTransform.simdTransform(azEl: azEl, distance: 500.0)
            
            // 3. Render
            if moonAnchor == nil {
                // Large enough to see at 500m (radius = 30 meters = 6x)
                let sphereMesh = MeshResource.generateSphere(radius: 30.0)
                let material = SimpleMaterial(color: .lightGray, isMetallic: false)
                let moonEntity = ModelEntity(mesh: sphereMesh, materials: [material])
                
                let anchor = AnchorEntity(world: transform)
                anchor.addChild(moonEntity)
                
                arView.scene.addAnchor(anchor)
                self.moonAnchor = anchor
            } else {
                // Update position
                moonAnchor?.transform = Transform(matrix: transform)
            }
        }
        
        func renderSun(observer: LocationContext, azimuthOffset: Double, elevationOffset: Double) {
            guard let arView = arView else { return }
            
            // 1. Calculate the math
            var azEl = AstroEngine.calculateSunPosition(date: Date(), observer: observer)
            
            // Apply Dynamic Calibration Offsets
            azEl.azimuth += azimuthOffset
            azEl.elevation += elevationOffset
            
            print("☀️ Sun Azimuth: \(azEl.azimuth), Elevation: \(azEl.elevation)")
            
            // 2. Transform Math to ARKit Native Coordinate Space (500 meters away)
            let transform = ARTransform.simdTransform(azEl: azEl, distance: 500.0)
            
            // 3. Render
            if sunAnchor == nil {
                // Large enough to see at 500m (radius = 30 meters = 6x)
                let sphereMesh = MeshResource.generateSphere(radius: 30.0)
                // Use UnlitMaterial so the sun always appears bright regardless of AR shadows
                let material = UnlitMaterial(color: UIColor(red: 1.0, green: 0.95, blue: 0.1, alpha: 1.0))
                let sunEntity = ModelEntity(mesh: sphereMesh, materials: [material])
                
                let anchor = AnchorEntity(world: transform)
                anchor.addChild(sunEntity)
                
                arView.scene.addAnchor(anchor)
                self.sunAnchor = anchor
            } else {
                // Update position
                sunAnchor?.transform = Transform(matrix: transform)
            }
        }
    }
}
#endif
