import Foundation

public extension AstroEngine {
    
    /// Calculated position of the Moon given a date and location context.
    /// This is an approximation (low precision) to prove ARKit sensor alignment is working.
    static func calculateMoonPosition(date: Date, observer: LocationContext) -> AzEl {
        // We will use a very simplified algorithm for testing
        // Standard Julian Date
        let jd = julianDate(for: date)
        
        // Julian days since J2000.0
        let d = jd - 2451545.0
        
        // Orbital elements of the Moon
        let N = 125.1228 - 0.0529538083 * d // Node
        let i = 5.1454 // Inclination
        let w = 318.0634 + 0.1643573223 * d // Longitude of perigee
        let a = 60.2666 // Semi-major axis in Earth radii
        let e = 0.054900 // Eccentricity
        let M = 115.3654 + 13.0649929509 * d // Mean anomaly
        
        // Normalize degrees
        func norm(_ angle: Double) -> Double {
            var res = angle.truncatingRemainder(dividingBy: 360.0)
            if res < 0 { res += 360.0 }
            return res
        }
        
        let N_norm = norm(N) * deg2rad
        let i_rad = i * deg2rad
        let w_arg_norm = norm(w - N) * deg2rad
        let M_norm = norm(M) * deg2rad
        
        // Eccentric anomaly
        var E = M_norm + e * sin(M_norm) * (1.0 + e * cos(M_norm))
        var E1 = E
        var count = 0
        repeat {
            E1 = E
            E = E1 - (E1 - e * sin(E1) - M_norm) / (1 - e * cos(E1))
            count += 1
        } while abs(E - E1) > 1e-6 && count < 10
        
        // Geocentric rectangular coordinates
        let xv = a * (cos(E) - e)
        let yv = a * (sqrt(1.0 - e * e) * sin(E))
        
        let v = atan2(yv, xv)
        let r = sqrt(xv * xv + yv * yv)
        
        // Longitude and latitude
        let lDiff = v + w_arg_norm
        let xh = r * (cos(N_norm) * cos(lDiff) - sin(N_norm) * sin(lDiff) * cos(i_rad))
        let yh = r * (sin(N_norm) * cos(lDiff) + cos(N_norm) * sin(lDiff) * cos(i_rad))
        let zh = r * (sin(lDiff) * sin(i_rad))
        
        var lon = atan2(yh, xh)
        let lat = atan2(zh, sqrt(xh * xh + yh * yh))
        
        // Calculate Right Ascension and Declination
        let ecl = (23.4393 - 3.563E-7 * d) * deg2rad
        
        let xeq = xh
        let yeq = yh * cos(ecl) - zh * sin(ecl)
        let zeq = yh * sin(ecl) + zh * cos(ecl)
        
        let ra = atan2(yeq, xeq)
        let dec = atan2(zeq, sqrt(xeq * xeq + yeq * yeq))
        
        // Topocentric Coordinates
        let latRad = observer.latitude * deg2rad
        let lonRad = observer.longitude * deg2rad
        
        let gmstRad = gmst(from: jd)
        var lstRad = gmstRad + lonRad
        lstRad = lstRad.truncatingRemainder(dividingBy: 2 * .pi)
        if lstRad < 0 { lstRad += 2 * .pi }
        
        let ha = lstRad - ra
        
        let sinAlt = sin(latRad) * sin(dec) + cos(latRad) * cos(dec) * cos(ha)
        let alt = asin(sinAlt)
        
        let cosAz = (sin(dec) - sinAlt * sin(latRad)) / (cos(alt) * cos(latRad))
        let sinAz = (-sin(ha) * cos(dec)) / cos(alt)
        
        var az = atan2(sinAz, cosAz) * rad2deg
        if az < 0 { az += 360.0 }
        
        let el = alt * rad2deg
        
        return AzEl(azimuth: az, elevation: el, range: r * earthRadiusKm)
    }
}
