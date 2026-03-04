import Foundation

public class AstroEngine {
    static let earthRadiusKm = 6378.137 // WGS84
    static let earthFlattening = 1.0 / 298.257223563
    static let mu = 398600.4418 // Earth's gravitational constant km^3/s^2
    static let deg2rad = Double.pi / 180.0
    static let rad2deg = 180.0 / Double.pi
    
    // Calculate Julian Date
    public static func julianDate(for date: Date) -> Double {
        return (date.timeIntervalSince1970 / 86400.0) + 2440587.5
    }
    
    // Calculate Greenwich Mean Sidereal Time (GMST) in radians
    public static func gmst(from julianDate: Double) -> Double {
        let d = julianDate - 2451545.0
        var gmstDeg = 280.46061837 + 360.98564736629 * d
        gmstDeg = gmstDeg.truncatingRemainder(dividingBy: 360.0)
        if gmstDeg < 0 { gmstDeg += 360.0 }
        return gmstDeg * deg2rad
    }
    
    // Keplarian Orbit to ECI (simplified, does not account for perturbations like SGP4)
    public static func keplerianToECI(tle: TLE, date: Date) -> ECI {
        let timeSinceEpochMinutes = date.timeIntervalSince(tle.epoch) / 60.0
        
        // Mean motion in radians per minute
        let n = tle.meanMotion * 2 * Double.pi / 1440.0
        
        // Semi-major axis
        let a = pow(mu / pow(n * 60.0, 2), 1.0 / 3.0)
        
        // Mean Anomaly at time
        var M = (tle.meanAnomaly * deg2rad) + (n * timeSinceEpochMinutes)
        M = M.truncatingRemainder(dividingBy: 2 * Double.pi)
        if M < 0 { M += 2 * Double.pi }
        
        // Solve Kepler's Equation for Eccentric Anomaly (E)
        var E = M
        var delta = 1.0
        let e = tle.eccentricity
        while abs(delta) > 1e-6 {
            delta = (E - e * sin(E) - M) / (1 - e * cos(E))
            E -= delta
        }
        
        // True Anomaly (v)
        let v = 2 * atan2(sqrt(1 + e) * sin(E / 2), sqrt(1 - e) * cos(E / 2))
        
        // Distance
        let r = a * (1 - e * cos(E))
        
        // Position in orbital plane
        let xOrbital = r * cos(v)
        let yOrbital = r * sin(v)
        
        let omega = tle.raan * deg2rad
        let w = tle.argPerigee * deg2rad
        let i = tle.inclination * deg2rad
        
        // Rotate to ECI
        let cosOmega = cos(omega)
        let sinOmega = sin(omega)
        let cosw = cos(w)
        let sinw = sin(w)
        let cosi = cos(i)
        let sini = sin(i)
        
        let xEci = xOrbital * (cosOmega * cosw - sinOmega * sinw * cosi) - yOrbital * (cosOmega * sinw + sinOmega * cosw * cosi)
        let yEci = xOrbital * (sinOmega * cosw + cosOmega * sinw * cosi) + yOrbital * (cosOmega * cosw * cosi - sinOmega * sinw)
        let zEci = xOrbital * (sinw * sini) + yOrbital * (cosw * sini)
        
        return ECI(x: xEci, y: yEci, z: zEci)
    }
    
    // ECI to ECEF (Earth-Centered, Earth-Fixed)
    public static func eciToEcef(eci: ECI, gmstRad: Double) -> ECEF {
        let x = eci.x * cos(gmstRad) + eci.y * sin(gmstRad)
        let y = -eci.x * sin(gmstRad) + eci.y * cos(gmstRad)
        let z = eci.z
        return ECEF(x: x, y: y, z: z)
    }
    
    // Location to ECEF
    public static func observerEcef(location: LocationContext) -> ECEF {
        let latRad = location.latitude * deg2rad
        let lonRad = location.longitude * deg2rad
        let altKm = location.altitude / 1000.0
        
        let sinLat = sin(latRad)
        let cosLat = cos(latRad)
        let sinLon = sin(lonRad)
        let cosLon = cos(lonRad)
        
        let e2 = 2 * earthFlattening - earthFlattening * earthFlattening
        let N = earthRadiusKm / sqrt(1 - e2 * sinLat * sinLat)
        
        let x = (N + altKm) * cosLat * cosLon
        let y = (N + altKm) * cosLat * sinLon
        let z = (N * (1 - e2) + altKm) * sinLat
        
        return ECEF(x: x, y: y, z: z)
    }
    
    // ECEF to ENU (East, North, Up) relative to observer
    public static func ecefToEnu(target: ECEF, observer: LocationContext) -> ENU {
        let obsEcef = observerEcef(location: observer)
        
        let dx = target.x - obsEcef.x
        let dy = target.y - obsEcef.y
        let dz = target.z - obsEcef.z
        
        let latRad = observer.latitude * deg2rad
        let lonRad = observer.longitude * deg2rad
        
        let sinLat = sin(latRad)
        let cosLat = cos(latRad)
        let sinLon = sin(lonRad)
        let cosLon = cos(lonRad)
        
        let e = -sinLon * dx + cosLon * dy
        let n = -sinLat * cosLon * dx - sinLat * sinLon * dy + cosLat * dz
        let u = cosLat * cosLon * dx + cosLat * sinLon * dy + sinLat * dz
        
        return ENU(e: e, n: n, u: u)
    }
    
    // ENU to Azimuth, Elevation, Range
    public static func enuToAzEl(enu: ENU) -> AzEl {
        let range = sqrt(enu.e * enu.e + enu.n * enu.n + enu.u * enu.u)
        
        var azimuth = atan2(enu.e, enu.n) * rad2deg
        if azimuth < 0 { azimuth += 360.0 }
        
        let elevation = asin(enu.u / range) * rad2deg
        
        return AzEl(azimuth: azimuth, elevation: elevation, range: range)
    }
    
    // End to end helper
    public static func calculateLookAngles(tle: TLE, date: Date, observer: LocationContext) -> AzEl {
        let jd = julianDate(for: date)
        let gmstRad = gmst(from: jd)
        
        let eci = keplerianToECI(tle: tle, date: date)
        let ecef = eciToEcef(eci: eci, gmstRad: gmstRad)
        let enu = ecefToEnu(target: ecef, observer: observer)
        return enuToAzEl(enu: enu)
    }
}
