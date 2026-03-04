# LaunchArc Development Roadmap (Vibe Coding Optimized)
**Status:** Draft | **Date:** March 3, 2026

This roadmap is optimized for a "vibe coding" approach (AI-assisted rapid iteration). Vibe coding is incredibly fast for UI, API integration, and scaffolding, but **it notoriously hallucinates and struggles with complex 3D math, spatial reasoning, and stateful native APIs like ARKit**. 

To succeed, we must decouple the "easy AI stuff" from the "hard AI stuff," aggressively test the math in isolation, and use real-world anchors (like the Sun or Moon) before trying to track a fast-moving rocket.

---

## Phase 1: Data & Math Isolation (De-risking the AI)
**Goal:** Build the skeleton, fetch the data, and nail the 3D math *without* touching ARKit yet. If the AI gets the math wrong, nothing else matters.
*   **The SwiftUI Shell:** *(Extremely high vibe-coding success rate).* Scaffold the app with a basic layout: Launch List, AR View (empty for now), Settings.
*   **API & TLE Ingestion:** *(High success rate).* Integrate Space Devs API to list upcoming launches. Parse TLE (Two-Line Element) sets into Swift structs.
*   **The Math Sandbox:** *(High risk of AI hallucination).* Create a pure Swift engine for astronomical calculations (converting TLE + user GPS to Azimuth/Elevation, and Az/El to local ARKit xyz coordinates).
*   **Math Unit Tests:** *(Crucial).* We must prompt the AI to generate unit tests for the math using known values (e.g., "If I am at GPS X, at Time Z, the Sun is at Azimuth A, Elevation B"). We cannot proceed until these exact tests pass.

## Phase 2: The "Hello Celestial Body" Prototype
**Goal:** Prove the ARKit projection works in the real world on a static target before worrying about moving rockets. 
*   **Basic AR Passthrough:** Initialize the AR session with `gravityAndHeading` alignment. 
*   **The Moon/Sun Test:** Instead of a rocket, we use our validated math to place a 3D sphere exactly where the Moon or Sun is currently located in the sky. 
*   **Real-World Vibe Check:** You physically go outside and point your phone at the moon. Does the AR sphere perfectly overlay the moon? If not, the AI failed on sensor alignment or coordinate projection. **We stop and iterate here until it is perfect.**
*   **The "Look Here" Arrow:** *(Medium risk).* Use SceneKit/ARKit to project the 3D target coordinates onto the 2D screen space to build the guiding arrow. AI sometimes messes up the screen-space projection math.

## Phase 3: The Rocket MVP
**Goal:** Swap the static celestial body for a dynamic, moving launch path.
*   **Local Visibility Matrix:** Calculate if the launch trajectory will technically break above your local true horizon. Update the SwiftUI list to say "Visible from your location."
*   **The AR Arc:** *(High risk).* Draw a sweeping, transparent procedural 3D curve in space representing the rocket's past and future path. AI often struggles with rendering smooth, complex 3D geometry in ARKit dynamically.
*   **Beta Test (The Real Deal):** Open the app during a live launch. Does the arc align with the real-life jellyfish or engine plume?

## Phase 4: V1 Polish & Launch
**Goal:** Wrap the verified core mechanic in premium UI and handle edge cases.
*   **HUD & Telemetry UI:** *(High success rate).* Overlay Altitude, Velocity, and Stage Events on the AR view. AI is fantastic at building slick HUDs.
*   **State Management:** Handle backgrounding, app switching, and location permissions smoothly. 
*   **Night Vision Mode:** Implement a "red-light" dark mode to preserve night vision.

---

### ⚠️ Critical Failure Points (Where Vibe Coding Will Break)
1. **Sensor Calibration:** The iPhone compass is easily perturbed by magnets (MagSafe) and buildings. AI won't instinctively build UI to tell the user "Wave your phone in a figure-8 to fix the compass". If tracking is off, this is likely the culprit, not the math.
2. **Spherical Trigonometry Hallucinations:** AI *will* confidently give you a valid-looking but incorrect mathematical formula for calculating Look Angles from TLE orbital data. We will need to verify its output against established standard libraries (like `sgp4`).
3. **ARKit Coordinate Collisions:** AI frequently confuses geographic coordinate space (relative to true north/equator) with relative world space (where the app started). We have to be very pedantic in our prompts to distinguish the two.
