import Foundation

public extension AstroEngine {
    
    /// Calculated position of the Sun given a date and location context.
    /// This is an approximation (low precision) to prove ARKit sensor alignment is working during the day.
    public static func calculateSunPosition(date: Date, observer: LocationContext) -> AzEl {
        // Standard Julian Date
        let jd = julianDate(for: date)
        
        // Days since J2000.0
        let d = jd - 2451545.0
        
        // Normalize degrees
        func norm(_ angle: Double) -> Double {
            var res = angle.truncatingRemainder(dividingBy: 360.0)
            if res < 0 { res += 360.0 }
            return res
        }
        
        // Mean anomaly of the Sun
        let M = norm(356.0470 + 0.9856002585 * d)
        let M_rad = M * deg2rad
        
        // Mean longitude of the Sun
        let L = norm(280.460 + 0.9856474 * d)
        
        // Ecliptic longitude of the Sun
        let lambda = norm(L + 1.915 * sin(M_rad) + 0.020 * sin(2 * M_rad))
        let lambdaRad = lambda * deg2rad
        
        // Obliquity of the ecliptic
        let epsilon = (23.4393 - 0.0000003563 * d)
        let epsilonRad = epsilon * deg2rad
        
        // Right ascension
        var ra = atan2(cos(epsilonRad) * sin(lambdaRad), cos(lambdaRad)) * rad2deg
        if ra < 0 { ra += 360.0 }
        let raRad = ra * deg2rad
        
        // Declination
        let decRad = asin(sin(epsilonRad) * sin(lambdaRad))
        
        // Distance to the sun in Astronomical Units (AU)
        let R = 1.00014 - 0.01671 * cos(M_rad) - 0.00014 * cos(2 * M_rad)
        let distanceKm = R * 149597870.7 // AU to km
        
        // Topocentric Coordinates
        let latRad = observer.latitude * deg2rad
        let lonRad = observer.longitude * deg2rad
        
        // Local Sidereal Time
        let gmstRad = gmst(from: jd)
        var lstRad = gmstRad + lonRad
        lstRad = lstRad.truncatingRemainder(dividingBy: 2 * .pi)
        if lstRad < 0 { lstRad += 2 * .pi }
        
        // Hour angle
        let haRad = lstRad - raRad
        
        // Elevation
        let sinAlt = sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(haRad)
        let altRad = asin(sinAlt)
        let elevation = altRad * rad2deg
        
        // Azimuth
        let cosAz = (sin(decRad) - sinAlt * sin(latRad)) / (cos(altRad) * cos(latRad))
        let sinAz = (-sin(haRad) * cos(decRad)) / cos(altRad)
        
        var azimuth = atan2(sinAz, cosAz) * rad2deg
        if azimuth < 0 { azimuth += 360.0 }
        
        return AzEl(azimuth: azimuth, elevation: elevation, range: distanceKm)
    }
}
