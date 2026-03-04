# PRD: LaunchArc – The AR Rocket Tracker
**Status:** Draft | **Date:** March 3, 2026
**Author:** Gemini (Collab with Mikhail Gorbachev) | **Platform:** iOS (iPhone-first)

## 1. Executive Summary
LaunchArc is an augmented reality (AR) iPhone application designed for remote observers of orbital launches. Unlike existing launch calendars, LaunchArc calculates the specific trajectory of a rocket relative to the user’s exact GPS coordinates and provides a "Star Walk" style AR overlay, showing the user exactly where the rocket will appear in their physical sky.

## 2. Problem Statement
Rocket launches are highly publicized, but for observers outside the immediate launch site (e.g., residents in Fairfield, CT watching a Florida launch), it is nearly impossible to know the exact azimuth and elevation to look at. Users miss once-in-a-lifetime "jellyfish" effects because they are looking 10 degrees too far left or waiting for a rocket that has already passed their horizon.

## 3. Goals & Objectives
- **Zero-Guesswork Observation:** Provide a real-time AR pointer that guides the user’s camera to the exact spot in the sky where the rocket is currently located.
- **Predictive Pathing:** Show the anticipated arc of the rocket before it even reaches the user's local horizon.
- **Stage Event Alerts:** Notify the user of key visual milestones (Max Q, Stage Separation, Entry Burn) so they know when to look for visual changes.

## 4. Functional Requirements
### 4.1 Core Features (MVP)
| Feature | Description | Priority |
| :--- | :--- | :--- |
| **AR Sky Overlay** | A transparent arc drawn on the sky showing the rocket’s past and future trajectory based on current T-minus/T-plus time. | P0 |
| **"Look Here" Guide** | An on-screen arrow that directs the user to pan their phone toward the rocket if it's not currently in the camera's FOV. | P0 |
| **Local Visibility Calc** | Calculates exactly when the rocket will "rise" and "set" relative to the user's Fairfield-specific horizon. | P0 |
| **Launch Calendar** | A curated list of upcoming global launches with a "Will I see this?" indicator based on geolocation. | P1 |
| **Stage Event HUD** | On-screen data showing current Altitude, Velocity, and upcoming events (e.g., "MECO in 10s"). | P1 |

### 4.2 User Stories
- As a user in Fairfield, I want to open the app 5 minutes before a SpaceX launch so I can see a line in the sky showing where the "jellyfish" plume will appear.
- As an amateur photographer, I want to see the maximum elevation (peak) of the rocket's path so I can set up my tripod in the right direction ahead of time.
- As a parent, I want a countdown and "look now" haptic vibration so my kids don't miss the 30-second window of visibility.

## 5. Technical Requirements
### 5.1 Technology Stack
- **Platform:** iOS 18+ (utilizing the latest ARKit and Metal for high-fidelity overlays).
- **Framework:** SwiftUI for the UI; ARKit for world-tracking and star-alignment.
- **Data Sources:** 
  - The Space Devs (Launch Library 2 API): For launch schedules and live status updates.
  - TLE (Two-Line Element) Sets / Flight Club: For precise trajectory math.
  - CoreLocation: To determine the user’s exact elevation and coordinates.

### 5.2 Performance Constraints
- **Latency:** Trajectory updates must be sub-second to match the live feed of the rocket.
- **Accuracy:** The AR overlay must be accurate within ±1 degree of the rocket's actual position in the sky.

## 6. Design & UX Principles
- **Dark Mode Native:** The app should default to a "red-light" or dark theme to preserve the user's night vision while sky-watching.
- **Minimalist HUD:** The camera view should not be cluttered; the focus is the sky, with data relegated to the edges of the screen.
- **Haptic Feedback:** Use distinct vibrations for "Rocket is now visible" and "Stage separation occurred."

## 7. Future Iterations (V2.0)
- **Social Observation:** See "pings" on the map where other users are currently watching the same launch.
- **Apple Vision Pro Integration:** A fully immersive "glass sky" experience.
- **Photo Mode:** Built-in long-exposure settings optimized for capturing rocket streaks.
