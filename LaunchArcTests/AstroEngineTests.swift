import XCTest
@testable import LaunchArc

final class AstroEngineTests: XCTestCase {

    func testJulianDate() {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar(identifier: .gregorian).date(from: components)!
        
        let jd = AstroEngine.julianDate(for: date)
        XCTAssertEqual(jd, 2451545.0, accuracy: 0.001)
    }
    
    func testTLEParsing() {
        // ISS TLE Example
        let name = "ISS (ZARYA)"
        let line1 = "1 25544U 98067A   23277.53032152  .00016717  00000-0  30184-3 0  9997"
        let line2 = "2 25544  51.6416 261.2721 0005477  70.8354   2.0526 15.50021576418833"
        
        guard let tle = TLE(name: name, line1: line1, line2: line2) else {
            XCTFail("Failed to parse TLE")
            return
        }
        
        XCTAssertEqual(tle.name, "ISS (ZARYA)")
        XCTAssertEqual(tle.inclination, 51.6416, accuracy: 0.0001)
        XCTAssertEqual(tle.raan, 261.2721, accuracy: 0.0001)
        XCTAssertEqual(tle.eccentricity, 0.0005477, accuracy: 0.0000001)
        XCTAssertEqual(tle.argPerigee, 70.8354, accuracy: 0.0001)
        XCTAssertEqual(tle.meanAnomaly, 2.0526, accuracy: 0.0001)
        XCTAssertEqual(tle.meanMotion, 15.50021576, accuracy: 0.00000001)
        
        let components = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: tle.epoch)
        XCTAssertEqual(components.year, 2023)
        // Check day roughly
        XCTAssertEqual(components.month, 10) // 277th day is roughly October 4th
    }
    
    func testCoordinateConversionIntegration() {
        // Just verify it doesn't return NaN and returns something reasonable for LEO
        let line1 = "1 25544U 98067A   23277.53032152  .00016717  00000-0  30184-3 0  9997"
        let line2 = "2 25544  51.6416 261.2721 0005477  70.8354   2.0526 15.50021576418833"
        let tle = TLE(name: "ISS", line1: line1, line2: line2)!
        
        let observer = LocationContext(latitude: 28.5721, longitude: -80.6480, altitude: 0) // Kennedy Space Center
        
        let azEl = AstroEngine.calculateLookAngles(tle: tle, date: tle.epoch, observer: observer)
        
        XCTAssertFalse(azEl.azimuth.isNaN)
        XCTAssertFalse(azEl.elevation.isNaN)
        XCTAssertFalse(azEl.range.isNaN)
        XCTAssertTrue(azEl.azimuth >= 0 && azEl.azimuth <= 360)
        XCTAssertTrue(azEl.elevation >= -90 && azEl.elevation <= 90)
    }

}
