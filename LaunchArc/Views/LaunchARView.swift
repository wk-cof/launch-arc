import SwiftUI
import RealityKit
import ARKit
import CoreLocation

struct LaunchARView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    
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
        context.coordinator.renderMoon(observer: observerContext)
        context.coordinator.renderSun(observer: observerContext)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        weak var arView: ARView?
        private var moonAnchor: AnchorEntity?
        private var sunAnchor: AnchorEntity?
        
        func renderMoon(observer: LocationContext) {
            guard let arView = arView else { return }
            
            // 1. Calculate the math
            let azEl = AstroEngine.calculateMoonPosition(date: Date(), observer: observer)
            print("🌑 Moon Azimuth: \(azEl.azimuth), Elevation: \(azEl.elevation)")
            
            // 2. Transform Math to ARKit Native Coordinate Space (500 meters away)
            let transform = ARTransform.simdTransform(azEl: azEl, distance: 500.0)
            
            // 3. Render
            if moonAnchor == nil {
                // Large enough to see at 500m (radius = 5 meters)
                let sphereMesh = MeshResource.generateSphere(radius: 5.0)
                let material = SimpleMaterial(color: .white, isMetallic: false)
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
        
        func renderSun(observer: LocationContext) {
            guard let arView = arView else { return }
            
            // 1. Calculate the math
            let azEl = AstroEngine.calculateSunPosition(date: Date(), observer: observer)
            print("☀️ Sun Azimuth: \(azEl.azimuth), Elevation: \(azEl.elevation)")
            
            // 2. Transform Math to ARKit Native Coordinate Space (500 meters away)
            let transform = ARTransform.simdTransform(azEl: azEl, distance: 500.0)
            
            // 3. Render
            if sunAnchor == nil {
                // Large enough to see at 500m (radius = 5 meters)
                let sphereMesh = MeshResource.generateSphere(radius: 5.0)
                let material = SimpleMaterial(color: .yellow, isMetallic: false)
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
