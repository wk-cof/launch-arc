import Foundation

public struct ECI {
    public var x: Double // km
    public var y: Double // km
    public var z: Double // km
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct ECEF {
    public var x: Double // km
    public var y: Double // km
    public var z: Double // km
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct ENU {
    public var e: Double // km
    public var n: Double // km
    public var u: Double // km
    
    public init(e: Double, n: Double, u: Double) {
        self.e = e
        self.n = n
        self.u = u
    }
}

public struct AzEl {
    public var azimuth: Double // degrees (0 is true North, 90 is East)
    public var elevation: Double // degrees (0 is horizon, 90 is zenith)
    public var range: Double // km
    
    public init(azimuth: Double, elevation: Double, range: Double) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.range = range
    }
}

public struct LocationContext {
    public var latitude: Double // degrees
    public var longitude: Double // degrees
    public var altitude: Double // meters
    
    public init(latitude: Double, longitude: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
}
