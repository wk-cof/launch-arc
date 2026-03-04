# LaunchArc Development Checklist

## Phase 1: Data & Math Isolation
- [x] Scaffold the basic SwiftUI shell (List, AR View empty placeholder, Settings)
- [ ] Integrate Space Devs API & TLE Ingestion to list upcoming launches
- [ ] Build pure Swift astronomical engine sandbox (TLE -> Az/El -> xyz)
- [ ] Write and pass pure math unit tests with verified known coordinates

## Phase 2: The "Hello Celestial Body" Prototype
- [ ] Initialize AR session with `gravityAndHeading` alignment (Basic AR Passthrough)
- [ ] Connect math engine to ARKit to place a sphere at the Moon/Sun's current projected location
- [ ] **Manual Review:** Go outside and physically verify the sphere overlaps the target body
- [ ] Implement the 3D-to-2D screen projection "Look Here" arrow

## Phase 3: The Rocket MVP
- [ ] Implement Local Visibility Matrix (horizon check) for launch list filtering
- [ ] Replace static sphere with a dynamic AR Arc representing the launch path
- [ ] **Manual Review:** Beta test during a live launch to test alignment and latency

## Phase 4: V1 Polish & Launch
- [ ] Overlay telemetry HUD on AR View 
- [ ] Add state management for location permissions and backgrounding
- [ ] Implement Night Vision Mode
